import AppKit
import Carbon
import VidradoCore

@MainActor final class HotKey {
    private var reference: EventHotKeyRef?
    private var handler: EventHandlerRef?
    var action: (() -> Void)?
    func register(key: UInt32, modifiers: UInt32) -> Bool {
        if let reference { UnregisterEventHotKey(reference); self.reference = nil }
        if handler == nil {
            var type = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
            let pointer = Unmanaged.passUnretained(self).toOpaque()
            InstallEventHandler(GetApplicationEventTarget(), { _, event, context in
                guard let context, let event else { return OSStatus(eventNotHandledErr) }
                var id = EventHotKeyID()
                guard GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &id) == noErr,
                      id.signature == 0x56494452, id.id == 1 else { return OSStatus(eventNotHandledErr) }
                MainActor.assumeIsolated { Unmanaged<HotKey>.fromOpaque(context).takeUnretainedValue().action?() }
                return noErr
            }, 1, &type, pointer, &handler)
        }
        let identifier = EventHotKeyID(signature: 0x56494452, id: 1)
        return RegisterEventHotKey(key, modifiers, identifier, GetApplicationEventTarget(), 0, &reference) == noErr
    }
    func unregister() {
        if let reference { UnregisterEventHotKey(reference) }; reference = nil
        if let handler { RemoveEventHandler(handler) }; handler = nil
    }
}

struct Shortcut {
    static func label(key: UInt32, modifiers: UInt32, spacing: String = "") -> String {
        let keys: [UInt32: String] = [0:"A",1:"S",2:"D",3:"F",4:"H",5:"G",6:"Z",7:"X",8:"C",9:"V",11:"B",12:"Q",13:"W",14:"E",15:"R",16:"Y",17:"T",18:"1",19:"2",20:"3",21:"4",22:"6",23:"5",24:"=",25:"9",26:"7",27:"−",28:"8",29:"0",30:"]",31:"O",32:"U",33:"[",34:"I",35:"P",37:"L",38:"J",39:"'",40:"K",41:";",42:"\\",43:",",44:"/",45:"N",46:"M",47:".",49:L10n.text("Space"),50:"`",123:"←",124:"→",125:"↓",126:"↑"]
        return [(modifiers & UInt32(controlKey) != 0 ? "⌃" : nil), (modifiers & UInt32(optionKey) != 0 ? "⌥" : nil), (modifiers & UInt32(shiftKey) != 0 ? "⇧" : nil), (modifiers & UInt32(cmdKey) != 0 ? "⌘" : nil), keys[key] ?? L10n.format("Key %@", String(key))].compactMap { $0 }.joined(separator: spacing)
    }
    static func carbonFlags(_ flags: NSEvent.ModifierFlags) -> UInt32 {
        (flags.contains(.command) ? UInt32(cmdKey) : 0) | (flags.contains(.option) ? UInt32(optionKey) : 0) |
        (flags.contains(.control) ? UInt32(controlKey) : 0) | (flags.contains(.shift) ? UInt32(shiftKey) : 0)
    }
}
