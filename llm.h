#ifndef LLM_SWIFT_H
#define LLM_SWIFT_H

#include <stdbool.h>

void* language_model_create();
bool model_is_available(void*);
void model_destroy(void*);

void* language_session_create(void*);
void session_respond_to(void*, char*, void(^)(char*, char*));
void session_respond_to_f(void*, char*, void*, void(*)(char*, char*, void*));
void session_destroy(void*);

#endif
