import AppKit

/// Owns the menu-bar status item. Keeps the app reachable with zero notes open.
@MainActor
final class StatusBarController: NSObject, NSMenuDelegate {

    private let item: NSStatusItem
    private var loginMenuItem: NSMenuItem!

    private let onNewNote: () -> Void
    private let onShowAll: () -> Void
    private let onHideAll: () -> Void
    private let onToggleLogin: () -> Void
    private let isLoginEnabled: () -> Bool
    private let onQuit: () -> Void

    init(onNewNote: @escaping () -> Void,
         onShowAll: @escaping () -> Void,
         onHideAll: @escaping () -> Void,
         onToggleLogin: @escaping () -> Void,
         isLoginEnabled: @escaping () -> Bool,
         onQuit: @escaping () -> Void) {

        self.onNewNote = onNewNote
        self.onShowAll = onShowAll
        self.onHideAll = onHideAll
        self.onToggleLogin = onToggleLogin
        self.isLoginEnabled = isLoginEnabled
        self.onQuit = onQuit

        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        if let button = item.button {
            button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "Sticky Notes")
            button.toolTip = "Sticky Notes"
        }
        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()
        menu.delegate = self

        addItem(to: menu, "New Note", #selector(newNoteAction), key: "n")
        menu.addItem(.separator())
        addItem(to: menu, "Show All Notes", #selector(showAllAction))
        addItem(to: menu, "Hide All Notes", #selector(hideAllAction))
        menu.addItem(.separator())
        loginMenuItem = addItem(to: menu, "Launch at Login", #selector(toggleLoginAction))
        menu.addItem(.separator())
        addItem(to: menu, "Quit Sticky Notes", #selector(quitAction), key: "q")

        item.menu = menu
    }

    @discardableResult
    private func addItem(to menu: NSMenu, _ title: String, _ action: Selector, key: String = "") -> NSMenuItem {
        let mi = NSMenuItem(title: title, action: action, keyEquivalent: key)
        mi.target = self
        menu.addItem(mi)
        return mi
    }

    // MARK: Actions

    @objc private func newNoteAction() { onNewNote() }
    @objc private func showAllAction() { onShowAll() }
    @objc private func hideAllAction() { onHideAll() }
    @objc private func toggleLoginAction() { onToggleLogin() }
    @objc private func quitAction() { onQuit() }

    // MARK: NSMenuDelegate

    func menuWillOpen(_ menu: NSMenu) {
        loginMenuItem.state = isLoginEnabled() ? .on : .off
    }
}
