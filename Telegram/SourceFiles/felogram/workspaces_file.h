#pragma once

#include <QtCore/QByteArray>
#include <QtCore/QString>
#include <optional>

namespace Felogram {

[[nodiscard]] std::optional<QByteArray> ReadWorkspaceFile(const QString &path);
[[nodiscard]] bool WriteWorkspaceFile(
	const QString &path,
	const QByteArray &expected,
	const QByteArray &encrypted);

} // namespace Felogram
