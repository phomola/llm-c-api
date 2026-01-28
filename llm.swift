import Foundation
import FoundationModels

@_cdecl("language_model_create")
public func language_model_create() -> OpaquePointer {
    let model = SystemLanguageModel.default
    return OpaquePointer(Unmanaged.passRetained(model).toOpaque())
}

@_cdecl("model_is_available")
public func model_is_available(_ model: OpaquePointer) -> CBool {
    let model = Unmanaged<SystemLanguageModel>.fromOpaque(UnsafeRawPointer(model)).takeUnretainedValue()
    return model.isAvailable
}

@_cdecl("model_destroy")
public func model_destroy(_ model: OpaquePointer) {
    _ = Unmanaged<SystemLanguageModel>.fromOpaque(UnsafeRawPointer(model)).takeRetainedValue()
}

@_cdecl("language_session_create")
public func language_session_create(_ model: OpaquePointer) -> OpaquePointer {
    let model = Unmanaged<SystemLanguageModel>.fromOpaque(UnsafeRawPointer(model)).takeUnretainedValue()
    let session = LanguageModelSession(model: model)    
    return OpaquePointer(Unmanaged.passRetained(session).toOpaque())
}

@_cdecl("session_respond_to")
public func session_respond_to(_ session: OpaquePointer, _ prompt: UnsafeMutablePointer<Int8>, _ callback: @convention(block) @escaping (UnsafeMutablePointer<Int8>?, UnsafeMutablePointer<Int8>?) -> Void) {
    let session = Unmanaged<LanguageModelSession>.fromOpaque(UnsafeRawPointer(session)).takeUnretainedValue()
    let prompt = String(cString: prompt)
    Task {
        do {
            let response = try await session.respond(to: prompt)
            callback(strdup(response.content), nil)
        } catch {
            callback(nil, strdup(error.localizedDescription))
        }
    }
}

@_cdecl("session_respond_to_f")
public func session_respond_to_f(_ session: OpaquePointer, _ prompt: UnsafeMutablePointer<Int8>, _ context: OpaquePointer, _ callback: @convention(c) (UnsafeMutablePointer<Int8>?, UnsafeMutablePointer<Int8>?, OpaquePointer) -> Void) {
    session_respond_to(session, prompt, { response, error in
        callback(response, error, context)
    })
}

@_cdecl("session_destroy")
public func session_destroy(_ session: OpaquePointer) {
    _ = Unmanaged<LanguageModelSession>.fromOpaque(UnsafeRawPointer(session)).takeRetainedValue()
}
