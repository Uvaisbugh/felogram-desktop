#include "felogram/workspaces_model.h"

#include <QtCore/QJsonArray>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
#include <QtCore/QUuid>
#include <algorithm>
#include <limits>

namespace Felogram {
namespace {

bool ValidMember(WorkspaceMember member) {
	return member.peer && member.topic >= 0
		&& member.topic <= std::numeric_limits<qint32>::max();
}

bool Decimal(const QJsonValue &value, quint64 &result) {
	if (!value.isString()) {
		return false;
	}
	auto ok = false;
	result = value.toString().toULongLong(&ok);
	return ok && QString::number(result) == value.toString();
}

} // namespace

Workspaces::Workspaces(quint64 owner, const QByteArray &data)
: _owner(owner) {
	if (!owner || data.size() > MaxBytes) {
		return;
	}
	if (data.isEmpty()) {
		_valid = true;
		return;
	}
	const auto document = QJsonDocument::fromJson(data);
	const auto root = document.object();
	auto storedOwner = quint64();
	if (!document.isObject() || root.value("version") != QJsonValue(1)
		|| !Decimal(root.value("owner"), storedOwner) || storedOwner != owner
		|| !root.value("selected").isString() || !root.value("workspaces").isArray()) {
		return;
	}
	const auto rows = root.value("workspaces").toArray();
	if (rows.size() > MaxWorkspaces) {
		return;
	}
	for (const auto row : rows) {
		const auto object = row.toObject();
		auto workspace = Workspace{ object.value("id").toString(), object.value("name").toString(), {} };
		if (QUuid(workspace.id).isNull() || find(workspace.id)
			|| !nameAllowed(workspace.name) || workspace.name != workspace.name.trimmed()
			|| !object.value("members").isArray()) {
			return;
		}
		const auto members = object.value("members").toArray();
		if (members.size() > MaxMembers) {
			return;
		}
		for (const auto value : members) {
			const auto memberObject = value.toObject();
			auto member = WorkspaceMember();
			auto topic = quint64();
			if (!Decimal(memberObject.value("peer"), member.peer)
				|| !Decimal(memberObject.value("topic"), topic)
				|| topic > quint64(std::numeric_limits<qint32>::max())) {
				return;
			}
			member.topic = qint64(topic);
			if (!ValidMember(member) || std::find(workspace.members.begin(), workspace.members.end(), member) != workspace.members.end()) {
				return;
			}
			workspace.members.push_back(member);
		}
		_list.push_back(std::move(workspace));
	}
	_selected = root.value("selected").toString();
	_valid = _selected.isEmpty() || find(_selected);
}

const Workspace *Workspaces::find(const QString &id) const {
	const auto i = std::find_if(_list.begin(), _list.end(), [&](const Workspace &row) { return row.id == id; });
	return (i == _list.end()) ? nullptr : &*i;
}

bool Workspaces::nameAllowed(const QString &name, const QString &except) const {
	return !name.isEmpty() && name.size() <= MaxName
		&& std::none_of(name.begin(), name.end(), [](QChar ch) { return ch.isNull() || ch.category() == QChar::Other_Control; })
		&& std::none_of(_list.begin(), _list.end(), [&](const Workspace &row) { return row.id != except && row.name.compare(name, Qt::CaseInsensitive) == 0; });
}

QByteArray Workspaces::serialize() const {
	if (!_valid) {
		return {};
	}
	auto rows = QJsonArray();
	for (const auto &workspace : _list) {
		auto members = QJsonArray();
		for (const auto member : workspace.members) {
			members.append(QJsonObject{ { "peer", QString::number(member.peer) }, { "topic", QString::number(member.topic) } });
		}
		rows.append(QJsonObject{ { "id", workspace.id }, { "name", workspace.name }, { "members", members } });
	}
	return QJsonDocument(QJsonObject{ { "version", 1 }, { "owner", QString::number(_owner) }, { "selected", _selected }, { "workspaces", rows } }).toJson(QJsonDocument::Compact);
}

QString Workspaces::create(QString name) {
	name = name.trimmed();
	if (!_valid || _list.size() >= MaxWorkspaces || !nameAllowed(name)) {
		return {};
	}
	const auto id = QUuid::createUuid().toString(QUuid::WithoutBraces);
	_list.push_back({ id, std::move(name), {} });
	_selected = id;
	return id;
}

bool Workspaces::rename(const QString &id, QString name) {
	name = name.trimmed();
	if (!_valid || !find(id) || !nameAllowed(name, id)) {
		return false;
	}
	for (auto &row : _list) {
		if (row.id == id) {
			row.name = std::move(name);
			break;
		}
	}
	return true;
}

bool Workspaces::move(const QString &id, int delta) {
	if (!_valid || (delta != -1 && delta != 1)) {
		return false;
	}
	for (auto i = 0; i < int(_list.size()); ++i) {
		if (_list[i].id == id && i + delta >= 0 && i + delta < int(_list.size())) {
			std::swap(_list[i], _list[i + delta]);
			return true;
		}
	}
	return false;
}

bool Workspaces::remove(const QString &id) {
	if (!_valid || !find(id)) {
		return false;
	}
	std::erase_if(_list, [&](const Workspace &row) { return row.id == id; });
	if (_selected == id) {
		_selected.clear();
	}
	return true;
}

bool Workspaces::select(const QString &id) {
	if (!_valid || (!id.isEmpty() && !find(id))) {
		return false;
	}
	_selected = id;
	return true;
}

bool Workspaces::add(const QString &id, WorkspaceMember member) {
	if (!_valid || !ValidMember(member)) {
		return false;
	}
	for (auto &row : _list) {
		if (row.id != id) {
			continue;
		}
		if (row.members.size() >= MaxMembers
			|| std::find(row.members.begin(), row.members.end(), member) != row.members.end()) {
			return false;
		}
		row.members.push_back(member);
		return true;
	}
	return false;
}

bool Workspaces::removeMember(const QString &id, WorkspaceMember member) {
	if (!_valid) {
		return false;
	}
	for (auto &row : _list) {
		if (row.id == id) {
			return std::erase(row.members, member) != 0;
		}
	}
	return false;
}

} // namespace Felogram
