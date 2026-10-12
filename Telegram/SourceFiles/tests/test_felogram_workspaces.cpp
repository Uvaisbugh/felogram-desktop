#include "felogram/workspaces_model.h"
#include "felogram/workspaces_file.h"
#include <QtCore/QLockFile>
#include <QtCore/QSaveFile>

#include <QtCore/QCoreApplication>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
#include <QtCore/QJsonArray>
#include <QtCore/QFile>
#include <QtCore/QTemporaryDir>
#include <cstdio>
#include <cstdlib>
#include <limits>

namespace {

void Check(bool value, const char *description) {
	if (!value) {
		std::fprintf(stderr, "FAIL: %s\n", description);
		std::exit(1);
	}
}

} // namespace

int main(int argc, char *argv[]) {
	const auto app = QCoreApplication(argc, argv);
	using Felogram::Workspaces;
	using Felogram::WorkspaceMember;
	auto model = Workspaces(100, {});
	Check(model.valid(), "new account");
	const auto project = model.create(QStringLiteral("  Project Alpha  "));
	const auto other = model.create(QStringLiteral("Other"));
	Check(!project.isEmpty() && !other.isEmpty(), "create");
	Check(model.find(project)->name == QStringLiteral("Project Alpha"), "trim names");
	Check(model.create(QStringLiteral("project alpha")).isEmpty(), "reject duplicate names");
	Check(model.create(QStringLiteral("\n")).isEmpty(), "reject empty names");
	Check(model.create(QString(81, QChar('a'))).isEmpty(), "bound names");
	const auto support = WorkspaceMember{ std::numeric_limits<quint64>::max(), 0 };
	const auto development = WorkspaceMember{ 456, 123 };
	const auto releases = WorkspaceMember{ 789, 0 };
	Check(model.add(project, support) && model.add(project, development)
		&& model.add(project, releases), "support development release entries");
	Check(!model.add(project, development), "reject duplicate entry");
	Check(model.add(project, { 456, 0 }), "chat and topic remain distinct");
	Check(!model.add(project, { 0, 0 }) && !model.add(project, { 456, -1 }), "reject invalid identifiers");
	Check(model.add(other, support), "overlapping membership");
	Check(model.move(other, -1) && !model.move(other, -1), "reorder with bounds");
	Check(model.rename(other, QString::fromUtf8("Tools \xF0\x9F\x94\xA7")), "unicode name");
	Check(!model.rename(other, QStringLiteral("PROJECT ALPHA")), "rename duplicate rejected");
	Check(model.select(project), "selected workspace");
	const auto bytes = model.serialize();
	const auto reopened = Workspaces(100, bytes);
	Check(reopened.valid() && reopened.selected() == project, "reopen selection");
	Check(reopened.list().front().id == other, "reopen ordering");
	Check(reopened.find(project)->members == model.find(project)->members, "lossless 64 bit identifiers and topic membership");
	Check(!Workspaces(101, bytes).valid(), "reject other account data");
	Check(!Workspaces(0, {}).valid(), "reject missing owner");
	Check(!Workspaces(100, bytes.left(bytes.size() / 2)).valid(), "reject truncation");
	Check(!Workspaces(100, QByteArray(Workspaces::MaxBytes + 1, 'x')).valid(), "bound input");
	auto root = QJsonDocument::fromJson(bytes).object();
	root["version"] = 2;
	Check(!Workspaces(100, QJsonDocument(root).toJson()).valid(), "reject unknown schema");
	root["version"] = 1;
	root["selected"] = QStringLiteral("missing");
	Check(!Workspaces(100, QJsonDocument(root).toJson()).valid(), "reject dangling selection");
	root["selected"] = project;
	auto rows = root["workspaces"].toArray();
	rows.append(rows.first());
	root["workspaces"] = rows;
	Check(!Workspaces(100, QJsonDocument(root).toJson()).valid(), "reject duplicate workspace");
	Check(model.removeMember(project, support), "remove membership");
	Check(model.find(other)->members.front() == support, "other workspace preserved");
	Check(model.remove(project) && model.selected().isEmpty(), "remove selected workspace");
	Check(model.find(other) && !model.find(project), "remove scope");
	Check(model.select({}), "all chats selection");
	auto limits = Workspaces(100, {});
	for (auto i = 0; i != Workspaces::MaxWorkspaces; ++i) {
		Check(!limits.create(QString::number(i)).isEmpty(), "within workspace limit");
	}
	Check(limits.create(QStringLiteral("overflow")).isEmpty(), "workspace limit");
	const auto id = limits.selected();
	for (auto i = 1; i <= Workspaces::MaxMembers; ++i) {
		Check(limits.add(id, { quint64(i), 0 }), "within member limit");
	}
	Check(!limits.add(id, { 999, 0 }), "member limit");
	Check(Workspaces(100, limits.serialize()).valid(), "limit roundtrip");
	const auto directory = QTemporaryDir();
	Check(directory.isValid(), "temporary test directory");
	const auto path = directory.path() + QStringLiteral("/account/felogram/workspaces");
	Check(Felogram::ReadWorkspaceFile(path) == QByteArray(), "missing store");
	Check(Felogram::WriteWorkspaceFile(path, {}, bytes), "first atomic write");
	Check(Felogram::ReadWorkspaceFile(path) == bytes, "reopen actual file");
	const auto changed = model.serialize();
	Check(Felogram::WriteWorkspaceFile(path, bytes, changed), "replace file");
	Check(!Felogram::WriteWorkspaceFile(path, bytes, bytes), "reject stale writer");
	Check(Felogram::ReadWorkspaceFile(path) == changed, "stale writer preserves file");
	{
		auto lock = QLockFile(path + QStringLiteral(".lock"));
		Check(lock.tryLock(), "lock fixture");
		Check(!Felogram::WriteWorkspaceFile(path, changed, bytes), "reject locked file");
	}
	{
		auto partial = QSaveFile(path);
		Check(partial.open(QIODevice::WriteOnly), "interrupted write fixture");
		partial.write("partial");
		partial.cancelWriting();
	}
	Check(Felogram::ReadWorkspaceFile(path) == changed, "cancelled replacement preserves file");
	Check(!Felogram::WriteWorkspaceFile(path + QStringLiteral("/invalid"), {}, bytes), "failed destination");
	Check(Felogram::ReadWorkspaceFile(path) == changed, "failed destination preserves file");
	Check(!Felogram::WriteWorkspaceFile(path, changed, {}), "reject empty replacement");
	const auto emptyPath = directory.path() + QStringLiteral("/empty");
	{
		auto empty = QFile(emptyPath);
		Check(empty.open(QIODevice::WriteOnly), "empty corruption fixture");
	}
	Check(!Felogram::ReadWorkspaceFile(emptyPath), "reject empty corrupt store");
	Check(!Felogram::WriteWorkspaceFile(emptyPath, {}, bytes), "preserve empty corrupt store");
	std::puts("PASS: workspace CRUD, ordering, membership, schema, limits, reopen and account isolation");
	return 0;
}
