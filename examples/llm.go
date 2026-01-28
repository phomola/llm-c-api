package main

import (
	"errors"
	"fmt"
	"os"
	"unsafe"
)

/*
#cgo LDFLAGS: -L.. -lllm

#include <stdlib.h>
#include "../llm.h"

void sessionCallback(char*, char*, uintptr_t);
*/
import "C"

type Model struct {
	ptr unsafe.Pointer
}

func NewModel() *Model {
	return &Model{ptr: C.language_model_create()}
}

func (m *Model) Close() {
	C.model_destroy(m.ptr)
}

type Session struct {
	ptr unsafe.Pointer
}

func NewSession(m *Model) *Session {
	return &Session{ptr: C.language_session_create(m.ptr)}
}

func (s *Session) Close() {
	C.session_destroy(s.ptr)
}

type sessionResponse struct {
	response string
	err      error
	ch       chan struct{}
}

//export sessionCallback
func sessionCallback(r, e *C.char, ctx uintptr) {
	defer C.free(unsafe.Pointer(r))
	defer C.free(unsafe.Pointer(e))
	resp := (*sessionResponse)(unsafe.Pointer(ctx))
	if r != nil {
		resp.response = C.GoString(r)
	} else {
		resp.err = errors.New(C.GoString(e))
	}
	resp.ch <- struct{}{}
}

func (s *Session) RespondTo(prompt string) (string, error) {
	cPrompt := C.CString(prompt)
	defer C.free(unsafe.Pointer(cPrompt))
	r := sessionResponse{ch: make(chan struct{}, 1)}
	C.session_respond_to_f(s.ptr, cPrompt, C.uintptr_t(uintptr(unsafe.Pointer(&r))), (*[0]byte)(C.sessionCallback))
	<-r.ch
	return r.response, r.err
}

func main() {
	model := NewModel()
	defer model.Close()
	session := NewSession(model)
	defer session.Close()
	response, err := session.RespondTo("Tell me the capital of Greenland.")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(response)
}
