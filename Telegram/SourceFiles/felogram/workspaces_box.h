#pragma once

namespace Window {
class SessionController;
} // namespace Window

namespace Felogram {

void ShowWorkspaces(not_null<Window::SessionController*> controller, bool choose = false);

} // namespace Felogram
