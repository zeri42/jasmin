(* ** Imports and settings *)
From mathcomp Require Import all_ssreflect all_algebra.
Require Import Sint63 strings utils gen_map tagged wsize.
Require Import Utf8.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Module Type CORE_IDENT.

  Parameter t  : Type.
  Parameter tag : t -> int.
  Parameter tagI : injective tag.

  Parameter name : Type.

  Parameter id_name : t -> name.
  Parameter id_kind : t -> wsize.v_kind.

  Parameter name_of_string : string → name.
  Parameter string_of_name : name → string.

  Parameter spill_to_mmx : t -> bool.

End CORE_IDENT.

(* An implementation of CORE_IDENT.
   The extraction overwrite it ... *)
Module Cident : CORE_IDENT.

  Definition t : Type := int.
  Definition tag (x : t) : int := x.

  Lemma tagI : injective tag.
  Proof. done. Qed.

  Definition name : Type := int.

  Definition id_name (x : t) : name := x.
  Definition id_kind of t := wsize.Const.

  Definition name_of_string of string := 1%uint63.
  Definition string_of_name of name := ""%string.

  Definition spill_to_mmx (x : t) := false.
End Cident.

Module Tident <: TAGGED with Definition t := Cident.t
  := Tagged (Cident).

#[global] Canonical ident_eqType  := Eval compute in Tident.t_eqType.

(* Necessary for extraction *)
Module WrapIdent.
  Definition t := Cident.t.
  Definition name  := Cident.name.
End WrapIdent.

Module Type IDENT.
  Definition ident := WrapIdent.t.
  Declare Module Mid : MAP with Definition K.t := [eqType of ident].
End IDENT.

Module Ident <: IDENT.

  Definition ident := WrapIdent.t.
  Definition name  := WrapIdent.name.
  Definition id_name : ident -> name := Cident.id_name.
  Definition id_kind : ident → wsize.v_kind := Cident.id_kind.

  Module Mid := Tident.Mt.

  Definition name_of_string : string → name := Cident.name_of_string.
  Definition string_of_name : name → string := Cident.string_of_name.

  Definition spill_to_mmx : ident -> bool := Cident.spill_to_mmx.
End Ident.
