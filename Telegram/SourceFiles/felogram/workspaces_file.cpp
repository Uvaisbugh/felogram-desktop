#include "felogram/workspaces_file.h"

#include "felogram/workspaces_model.h"
#include <QtCore/QDir>
#include <QtCore/QFile>
#include <QtCore/QFileInfo>
#include <QtCore/QLockFile>
#include <QtCore/QSaveFile>

namespace Felogram {

std::optional<QByteArray> ReadWorkspaceFile(const QString &path) {
	auto file = QFile(path);
	if (!file.exists()) {
		return QByteArray();
	}
	if (!file.open(QIODevice::ReadOnly)
		|| file.size() == 0
		|| file.size() > Workspaces::MaxBytes + 64) {
		return std::nullopt;
	}
	const auto bytes = file.readAll();
	return file.error() == QFileDevice::NoError
		? std::optional<QByteArray>(bytes) : std::nullopt;
}

bool WriteWorkspaceFile(
		const QString &path,
		const QByteArray &expected,
		const QByteArray &encrypted) {
	if (encrypted.isEmpty() || encrypted.size() > Workspaces::MaxBytes + 64
		|| !QDir().mkpath(QFileInfo(path).absolutePath())) {
		return false;
	}
	auto lock = QLockFile(path + QStringLiteral(".lock"));
	if (!lock.tryLock()) {
		return false;
	}
	const auto previous = ReadWorkspaceFile(path);
	if (!previous || *previous != expected) {
		return false;
	}
	auto file = QSaveFile(path);
	file.setDirectWriteFallback(false);
	return file.open(QIODevice::WriteOnly)
		&& file.write(encrypted) == encrypted.size()
		&& file.commit();
}

} // namespace Felogram
