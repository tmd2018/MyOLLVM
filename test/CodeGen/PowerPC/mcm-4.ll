; RUN: llc -mcpu=pwr7 -O0 -code-model=medium -fast-isel=false -mattr=-vsx <%s | FileCheck -check-prefix=MEDIUM %s
; RUN: llc -mcpu=pwr7 -O0 -code-model=medium -fast-isel=false -mattr=+vsx <%s | FileCheck -check-prefix=MEDIUM-VSX %s
; RUN: llc -mcpu=pwr7 -O0 -code-model=large -fast-isel=false -mattr=-vsx <%s | FileCheck -check-prefix=LARGE %s
; RUN: llc -mcpu=pwr7 -O0 -code-model=large -fast-isel=false -mattr=+vsx <%s | FileCheck -check-prefix=LARGE-VSX %s

; Test correct code generation for medium and large code model
; for loading a value from the constant pool (TOC-relative).

target datalayout = "E-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-f128:128:128-v128:128:128-n32:64"
target triple = "powerpc64-unknown-linux-gnu"

define double @test_double_const() nounwind {
entry:
  ret double 0x3F4FD4920B498CF0
}

; MEDIUM: [[VAR:[a-z0-9A-Z_.]+]]:
; MEDIUM: .quad 4562098671269285104
; MEDIUM-LABEL: test_double_const:
; MEDIUM: addis [[REG1:[0-9]+]], 2, [[VAR]]@toc@ha
; MEDIUM: addi [[REG2:[0-9]+]], [[REG1]], [[VAR]]@toc@l
; MEDIUM: lfd {{[0-9]+}}, 0([[REG2]])

; MEDIUM-VSX: [[VAR:[a-z0-9A-Z_.]+]]:
; MEDIUM-VSX: .quad 4562098671269285104
; MEDIUM-VSX-LABEL: test_double_const:
; MEDIUM-VSX: addis [[REG1:[0-9]+]], 2, [[VAR]]@toc@ha
; MEDIUM-VSX: addi [[REG2:[0-9]+]], [[REG1]], [[VAR]]@toc@l
; MEDIUM-VSX: lxsdx {{[0-9]+}}, 0, [[REG2]]

; LARGE: [[VAR:[a-z0-9A-Z_.]+]]:
; LARGE: .quad 4562098671269285104
; LARGE-LABEL: test_double_const:
; LARGE: addis [[REG1:[0-9]+]], 2, [[VAR2:[a-z0-9A-Z_.]+]]@toc@ha
; LARGE: ld [[REG2:[0-9]+]], [[VAR2]]@toc@l([[REG1]])
; LARGE: lfd {{[0-9]+}}, 0([[REG2]])

; LARGE-VSX: [[VAR:[a-z0-9A-Z_.]+]]:
; LARGE-VSX: .quad 4562098671269285104
; LARGE-VSX-LABEL: test_double_const:
; LARGE-VSX: addis [[REG1:[0-9]+]], 2, [[VAR2:[a-z0-9A-Z_.]+]]@toc@ha
; LARGE-VSX: ld [[REG2:[0-9]+]], [[VAR2]]@toc@l([[REG1]])
; LARGE-VSX: lxsdx {{[0-9]+}}, 0, [[REG2]]
