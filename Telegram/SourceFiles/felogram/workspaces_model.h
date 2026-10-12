#pragma once

#include <QtCore/QByteArray>
#include <QtCore/QString>
#include <vector>

namespace Felogram {

struct WorkspaceMember {
	quint64 peer = 0;
	qint64 topic = 0;
	bool operator==(const WorkspaceMember&) const = default;
};

struct Workspace {
	QString id;
	QString name;
	std::vector<WorkspaceMember> members;
};

class Workspaces final {
public:
	static constexpr auto MaxBytes = 1024 * 1024;
	static constexpr auto MaxWorkspaces = 32;
	static constexpr auto MaxMembers = 200;
	static constexpr auto MaxName = 80;

	Workspaces(quint64 owner, const QByteArray &data);
	[[nodiscard]] bool valid() const { return _valid; }
	[[nodiscard]] const std::vector<Workspace> &list() const { return _list; }
	[[nodiscard]] const QString &selected() const { return _selected; }
	[[nodiscard]] const Workspace *find(const QString &id) const;
	[[nodiscard]] QByteArray serialize() const;
	QString create(QString name);
	bool rename(const QString &id, QString name);
	bool move(const QString &id, int delta);
	bool remove(const QString &id);
	bool select(const QString &id);
	bool add(const QString &id, WorkspaceMember member);
	bool removeMember(const QString &id, WorkspaceMember member);

private:
	[[nodiscard]] bool nameAllowed(const QString &name, const QString &except = {}) const;
	quint64 _owner = 0;
	bool _valid = false;
	QString _selected;
	std::vector<Workspace> _list;

};

} // namespace Felogram
