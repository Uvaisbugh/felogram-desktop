#include "felogram/workspaces_box.h"

#include "felogram/workspaces_model.h"
#include "core/application.h"
#include "main/main_session.h"
#include "storage/storage_account.h"
#include "data/data_session.h"
#include "data/data_user.h"
#include "data/data_chat.h"
#include "data/data_channel.h"
#include "data/data_forum.h"
#include "data/data_forum_topic.h"
#include "dialogs/dialogs_key.h"
#include "dialogs/dialogs_common.h"
#include "dialogs/dialogs_entry.h"
#include "base/weak_ptr.h"
#include "ui/widgets/buttons.h"
#include "history/history.h"
#include "lang/lang_keys.h"
#include "settings/settings_common.h"
#include "ui/boxes/confirm_box.h"
#include "ui/widgets/fields/input_field.h"
#include "ui/widgets/labels.h"
#include "ui/wrap/vertical_layout.h"
#include "window/window_session_controller.h"
#include "styles/style_boxes.h"
#include "styles/style_layers.h"
#include "styles/style_settings.h"
#include <QtCore/QTimer>

namespace Felogram {
namespace {

constexpr auto kUnreadRefreshInterval = 1000;

void Error(not_null<Window::SessionController*> controller) {
	controller->show(Ui::MakeInformBox(tr::lng_felogram_workspace_save_error()));
}

bool Change(
		not_null<Window::SessionController*> controller,
		Fn<bool(Workspaces&)> change) {
	if (Core::App().passcodeLocked()) {
		return false;
	}
	auto &session = controller->session();
	const auto previous = session.local().readFelogramWorkspaces();
	auto model = Workspaces(session.userId().bare, previous.value_or(QByteArray()));
	if (!previous || !model.valid() || !change(model)
		|| !session.local().writeFelogramWorkspaces(*previous, model.serialize())) {
		Error(controller);
		return false;
	}
	return true;
}

void Bind(not_null<Ui::GenericBox*> box, not_null<Window::SessionController*> controller) {
	const auto weak = base::make_weak(box);
	controller->lifetime().add([=] {
		if (weak) {
			weak->closeBox();
		}
	});
}

void Label(not_null<Ui::GenericBox*> box, QString text) {
	box->addRow(object_ptr<Ui::FlatLabel>(box, std::move(text), st::boxLabel));
}

void Button(not_null<Ui::GenericBox*> box, QString text, Fn<void()> callback) {
	const auto button = box->addRow(Settings::CreateButtonWithIcon(
		box, rpl::single(std::move(text)), st::settingsButton));
	button->setClickedCallback(std::move(callback));
	button->setFocusPolicy(Qt::StrongFocus);
}

void EditName(not_null<Window::SessionController*> controller, QString id, QString name) {
	controller->show(Box([=](not_null<Ui::GenericBox*> box) {
		Bind(box, controller);
		box->setTitle(id.isEmpty() ? tr::lng_felogram_workspace_create() : tr::lng_felogram_workspace_rename());
		const auto input = box->addRow(object_ptr<Ui::InputField>(box,
			st::defaultInputField, Ui::InputField::Mode::SingleLine,
			tr::lng_felogram_workspace_name(), name));
		const auto save = [=] {
			if (Change(controller, [&](Workspaces &model) {
				return id.isEmpty() ? !model.create(input->getLastText()).isEmpty() : model.rename(id, input->getLastText());
			})) {
				box->closeBox();
				ShowWorkspaces(controller);
			}
		};
		box->addButton(tr::lng_settings_save(), save);
		box->addButton(tr::lng_cancel(), [=] { box->closeBox(); });
		input->submits() | rpl::on_next(save, input->lifetime());
		box->setFocusCallback([=] { input->setFocusFast(); });
	}));
}

Dialogs::Key Resolve(not_null<Main::Session*> session, WorkspaceMember member) {
	const auto peer = session->data().peerLoaded(PeerId(member.peer));
	if (!peer || (peer->asUser() && peer->asUser()->isInaccessible())
		|| (peer->asChat() && !peer->asChat()->amIn())
		|| (peer->asChannel() && !peer->asChannel()->amIn())) {
		return {};
	}
	if (member.topic) {
		const auto channel = peer->asChannel();
		const auto forum = channel ? channel->forum() : nullptr;
		return forum ? Dialogs::Key(forum->topicFor(MsgId(member.topic))) : Dialogs::Key();
	}
	return session->data().historyLoaded(peer);
}

QString MemberText(not_null<Main::Session*> session, WorkspaceMember member) {
	const auto key = Resolve(session, member);
	if (!key) {
		return tr::lng_felogram_workspace_unavailable(tr::now);
	}
	auto text = key.peer()->isSelf()
		? tr::lng_saved_messages(tr::now)
		: key.peer()->name();
	if (const auto topic = key.topic()) {
		text += u" / "_q + topic->title();
	}
	const auto unread = key.entry()->chatListUnreadState();
	if (!unread.known) {
		text += u" Ã‚Â· "_q + tr::lng_felogram_workspace_unread_unknown(tr::now);
	} else if (unread.messages) {
		text += u" Ã‚Â· "_q + QString::number(unread.messages);
	} else if (unread.marks) {
		text += u" Ã‚Â· "_q + tr::lng_felogram_workspace_unread(tr::now);
	}
	return text;
}

void OpenMember(not_null<Window::SessionController*> controller, not_null<Ui::GenericBox*> box, WorkspaceMember member) {
	if (Core::App().passcodeLocked()) {
		return;
	}
	const auto key = Resolve(&controller->session(), member);
	if (key) {
		box->closeBox();
		if (const auto topic = key.topic()) {
			controller->showTopic(topic);
		} else {
			controller->showPeerHistory(key.peer());
		}
		return;
	}
	const auto peer = controller->session().data().peerLoaded(PeerId(member.peer));
	const auto channel = peer ? peer->asChannel() : nullptr;
	const auto forum = channel ? channel->forum() : nullptr;
	if (member.topic && forum && channel->amIn() && !forum->topicDeleted(MsgId(member.topic))) {
		const auto weak = base::make_weak(box);
		const auto owner = base::make_weak(controller);
		forum->requestTopic(MsgId(member.topic), [=] {
			if (!weak || !owner || Core::App().passcodeLocked()) {
				return;
			}
			const auto resolved = Resolve(&controller->session(), member);
			if (resolved) {
				weak->closeBox();
				controller->showTopic(resolved.topic());
			} else {
				controller->show(Ui::MakeInformBox(tr::lng_felogram_workspace_unavailable_help()));
			}
		});
	} else {
		controller->show(Ui::MakeInformBox(tr::lng_felogram_workspace_unavailable_help()));
	}
}

} // namespace

void ShowWorkspaces(not_null<Window::SessionController*> controller, bool choose) {
	if (Core::App().passcodeLocked()) {
		return;
	}
	controller->show(Box([=](not_null<Ui::GenericBox*> box) {
		Bind(box, controller);
		box->setTitle(tr::lng_felogram_workspaces());
		box->setWidth(st::boxWideWidth);
		box->addButton(tr::lng_close(), [=] { box->closeBox(); });
		auto &session = controller->session();
		Label(box, tr::lng_felogram_workspace_account(tr::now, lt_name, session.user()->name()));
		const auto bytes = session.local().readFelogramWorkspaces();
		const auto model = Workspaces(session.userId().bare, bytes.value_or(QByteArray()));
		if (!bytes || !model.valid()) {
			Label(box, tr::lng_felogram_workspace_read_error(tr::now));
			return;
		}
		Button(box, tr::lng_felogram_workspace_all(tr::now), [=] {
			if (Change(controller, [](Workspaces &model) { return model.select({}); })) {
				box->closeBox();
			}
		});
		const auto selected = choose ? nullptr : model.find(model.selected());
		if (!selected) {
			for (const auto &workspace : model.list()) {
				Button(box, workspace.name, [=, id = workspace.id] {
					if (Change(controller, [&](Workspaces &model) { return model.select(id); })) {
						box->closeBox();
						ShowWorkspaces(controller);
					}
				});
			}
			Button(box, tr::lng_felogram_workspace_create(tr::now), [=] {
				box->closeBox();
				EditName(controller, {}, {});
			});
			return;
		}
		const auto id = selected->id;
		Label(box, selected->name);
		Button(box, tr::lng_felogram_workspace_choose(tr::now), [=] {
			box->closeBox();
			ShowWorkspaces(controller, true);
		});
		if (selected->members.empty()) {
			Label(box, tr::lng_felogram_workspace_empty(tr::now));
		}
		const auto timer = new QTimer(box);
		const auto owner = base::make_weak(controller);
		for (const auto member : selected->members) {
			const auto text = box->lifetime().make_state<rpl::variable<QString>>(MemberText(&session, member));
			const auto row = box->addRow(Settings::CreateButtonWithIcon(box, text->value(), st::settingsButton));
			row->setFocusPolicy(Qt::StrongFocus);
			row->setClickedCallback([=] { OpenMember(controller, box, member); });
			QObject::connect(timer, &QTimer::timeout, row, [=] {
				if (owner) {
					*text = MemberText(&owner->session(), member);
				}
			});
			Button(box, tr::lng_felogram_workspace_remove_member(tr::now), [=] {
				if (Change(controller, [&](Workspaces &model) { return model.removeMember(id, member); })) {
					box->closeBox();
					ShowWorkspaces(controller);
				}
			});
		}
		timer->start(kUnreadRefreshInterval);
		const auto current = controller->activeChatCurrent();
		if (current.peer() && !current.sublist()) {
			const auto member = WorkspaceMember{ current.peer()->id.value, current.topic() ? current.topic()->rootId().bare : 0 };
			const auto present = std::find(selected->members.begin(), selected->members.end(), member) != selected->members.end();
			if (!present && selected->members.size() < Workspaces::MaxMembers) {
				Button(box, tr::lng_felogram_workspace_add_current(tr::now), [=] {
					if (Change(controller, [&](Workspaces &model) {
						return model.add(id, member);
					})) {
						box->closeBox();
						ShowWorkspaces(controller);
					}
				});
			}
		}
		Button(box, tr::lng_felogram_workspace_rename(tr::now), [=, name = selected->name] {
			box->closeBox();
			EditName(controller, id, name);
		});
		const auto index = int(selected - model.list().data());
		for (const auto delta : { -1, 1 }) {
			if (index + delta < 0 || index + delta >= int(model.list().size())) {
				continue;
			}
			Button(box, delta < 0 ? tr::lng_felogram_workspace_up(tr::now) : tr::lng_felogram_workspace_down(tr::now), [=] {
				if (Change(controller, [&](Workspaces &model) { return model.move(id, delta); })) {
					box->closeBox();
					ShowWorkspaces(controller, true);
				}
			});
		}
		Button(box, tr::lng_felogram_workspace_remove(tr::now), [=] {
			controller->show(Ui::MakeConfirmBox({
				.text = tr::lng_felogram_workspace_remove_confirm(tr::now),
				.confirmed = [=](Fn<void()> close) {
					if (Change(controller, [&](Workspaces &model) { return model.remove(id); })) {
						close();
						box->closeBox();
						ShowWorkspaces(controller, true);
					}
				},
			}));
		});
	}));
}

} // namespace Felogram
