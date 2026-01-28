#include <stdio.h>
#include <unistd.h>
#include <dispatch/dispatch.h>
#include "../llm.h"

int main() {
    void* model = language_model_create();
    bool modelIsAvailable = model_is_available(model);
    printf("LLM is available: %s\n", modelIsAvailable ? "yes" : "no");
    if (!modelIsAvailable) exit(1);

    void* session = language_session_create(model);
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    session_respond_to(session, "Tell me the capital of Greenland.", ^(char* response, char* error) {
        printf("'%s' '%s'\n", response, error);
        free(response);
        free(error);
        dispatch_semaphore_signal(sem);
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    dispatch_release(sem);    
    session_destroy(session);
    model_destroy(model);
}
