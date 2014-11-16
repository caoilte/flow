(**
 *  Copyright 2014 Facebook.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *)

module Ast = Spider_monkey_ast

let id_nop _ _ _ = false

let member_nop _ _ _ _ = false

let call_nop _ _ _ _ = ()

type hook_state_t = {
  id_hook:
     (Constraint_js.context ->
      string -> Ast.Loc.t ->
      bool);

  member_hook:
     (Constraint_js.context ->
      string -> Ast.Loc.t -> Constraint_js.Type.t ->
      bool);

(* TODO: This is inconsistent with the way the id/member hooks work, but we
         currently don't need a way to override call types, so it simplifies
         things a bit *)
  call_hook:
     (Constraint_js.context ->
      string -> Ast.Loc.t -> Constraint_js.Type.t ->
      unit);
}

let nop_hook_state = {
  id_hook = id_nop;
  member_hook = member_nop;
  call_hook = call_nop;
}

let hook_state = ref nop_hook_state

let set_id_hook hook =
  hook_state := { !hook_state with id_hook = hook }

let set_member_hook hook =
  hook_state := { !hook_state with member_hook = hook }

let set_call_hook hook =
  hook_state := { !hook_state with call_hook = hook }

let reset_hooks () =
  hook_state := nop_hook_state

let dispatch_id_hook name loc =
  !hook_state.id_hook name loc

let dispatch_member_hook name loc this_t =
  !hook_state.member_hook name loc this_t

let dispatch_call_hook name loc this_t =
  !hook_state.call_hook name loc this_t
