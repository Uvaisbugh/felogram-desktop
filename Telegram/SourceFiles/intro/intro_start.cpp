/*
This file is part of Telegram Desktop,
the official desktop application for the Telegram messaging service.

For license and copyright information please follow this link:
https://github.com/telegramdesktop/tdesktop/blob/master/LEGAL
*/
#include "intro/intro_start.h"

#include "lang/lang_keys.h"
#include "core/version.h"
#include "core/file_utilities.h"
#include "felogram_api_config.h"
#include "felogram_build.h"
#include "intro/intro_qr.h"
#include "intro/intro_phone.h"
#include "ui/widgets/buttons.h"
#include "ui/widgets/labels.h"
#include "main/main_account.h"
#include "main/main_app_config.h"

namespace Intro {
namespace details {

StartWidget::StartWidget(
	QWidget *parent,
	not_null<Main::Account*> account,
	not_null<Data*> data)
: Step(parent, account, data, true) {
	setMouseTracking(true);
	setTitleText(rpl::single(AppName.utf16()));
	setDescriptionText(Felogram::BaselineApi
		? tr::lng_felogram_baseline_setup()
		: tr::lng_felogram_intro_about());
	show();
}

void StartWidget::submit() {
	if (Felogram::BaselineApi) {
		File::OpenUrl(u"https://github.com/Uvaisbugh/felogram-desktop/blob/%1/docs/REAL_ACCOUNT_TESTING.md"_q.arg(
			QString::fromLatin1(Felogram::SourceRevision).left(40)));
		return;
	}
	account().destroyStaleAuthorizationKeys();
	goNext<QrWidget>();
}

rpl::producer<QString> StartWidget::nextButtonText() const {
	return Felogram::BaselineApi ? tr::lng_felogram_setup_api() : tr::lng_start_msgs();
}

rpl::producer<> StartWidget::nextButtonFocusRequests() const {
	return _nextButtonFocusRequests.events();
}

void StartWidget::activate() {
	Step::activate();
	setInnerFocus();
}

void StartWidget::setInnerFocus() {
	_nextButtonFocusRequests.fire({});
}

} // namespace details
} // namespace Intro
