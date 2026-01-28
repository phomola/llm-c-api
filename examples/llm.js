import { delay } from "@std/async/delay"

const lib = Deno.dlopen("libllm.dylib", {
    language_model_create: { parameters: [], result: "pointer" },
    model_is_available: { parameters: ["pointer"], result: "bool" },
    model_destroy: { parameters: ["pointer"], result: "void" },
    language_session_create: { parameters: [], result: "pointer" },
    session_respond_to_f: { parameters: ["pointer", "buffer", "pointer", "function"], result: "void" },
    session_destroy: { parameters: ["pointer"], result: "void" },
})

const model = lib.symbols.language_model_create()
const session = lib.symbols.language_session_create(model)

const callback = new Deno.UnsafeCallback(
    { parameters: ["pointer", "pointer", "pointer"], result: "void" },
    (response, error, context) => {
        if (response != null) {
            console.log(new Deno.UnsafePointerView(response).getCString())
        } else {
            console.log(new Deno.UnsafePointerView(error).getCString())
        }
    },
)
lib.symbols.session_respond_to_f(session, new TextEncoder().encode("Tell me the capital of Greenland."), null, callback.pointer)
await delay(10_000)
callback.close()

lib.symbols.session_destroy(session)
lib.symbols.model_destroy(model)
lib.close()
