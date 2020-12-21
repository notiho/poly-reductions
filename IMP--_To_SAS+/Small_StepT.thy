\<^marker>\<open>creator Bilel Ghorbel, Florian Kessler\<close>

section "Small step semantics of IMP- "

subsection "Small step semantics definition"
theory Small_StepT  imports Main Com "../IMP-/Rel_Pow" begin

paragraph "Summary"
text\<open>We give small step semantics with time for IMP-. 
Based on the small step semantics definition time for IMP\<close>

inductive
  small_step :: "com * state \<Rightarrow> com * state \<Rightarrow> bool"  (infix "\<rightarrow>" 55)
where
Assign:  "(x ::= a, s) \<rightarrow> (SKIP, s(x := aval a s))" |

Seq1:    "(SKIP;;c\<^sub>2,s) \<rightarrow> (c\<^sub>2,s)" |
Seq2:    "(c\<^sub>1,s) \<rightarrow> (c\<^sub>1',s') \<Longrightarrow> (c\<^sub>1;;c\<^sub>2,s) \<rightarrow> (c\<^sub>1';;c\<^sub>2,s')" |

IfTrue:  "s b \<noteq> 0 \<Longrightarrow> (IF b \<noteq>0 THEN c\<^sub>1 ELSE c\<^sub>2,s) \<rightarrow> (c\<^sub>1,s)" |
IfFalse: "s b = 0 \<Longrightarrow> (IF b \<noteq>0  THEN c\<^sub>1 ELSE c\<^sub>2,s) \<rightarrow> (c\<^sub>2,s)" |

WhileTrue:   "s b \<noteq> 0 \<Longrightarrow> (WHILE b\<noteq>0 DO c,s) \<rightarrow>
            (c ;; (WHILE b \<noteq>0 DO c), s)" |
WhileFalse:   "s b = 0 \<Longrightarrow> (WHILE b\<noteq>0 DO c,s) \<rightarrow>
            (SKIP,s)"

subsection "Transitive Closure"
abbreviation
  small_step_pow :: "com * state \<Rightarrow> nat \<Rightarrow> com * state \<Rightarrow> bool" ("_ \<rightarrow>\<^bsup>_\<^esup> _" 55)
  where "x \<rightarrow>\<^bsup>t\<^esup> y == (rel_pow  small_step t)  x y"

bundle small_step_syntax
begin
notation small_step (infix "\<rightarrow>" 55) and
         small_step_pow ("_ \<rightarrow>\<^bsup>_\<^esup> _" 55)
end

bundle no_small_step_syntax
begin
no_notation small_step (infix "\<rightarrow>" 55) and
            small_step_pow ("_ \<rightarrow>\<^bsup>_\<^esup> _" 55)
end

subsection\<open>Executability\<close>

code_pred small_step .

subsection\<open>Proof infrastructure\<close>

subsubsection\<open>Induction rules\<close>

text\<open>The default induction rule @{thm[source] small_step.induct} only works
for lemmas of the form \<open>a \<rightarrow> b \<Longrightarrow> \<dots>\<close> where \<open>a\<close> and \<open>b\<close> are
not already pairs \<open>(DUMMY,DUMMY)\<close>. We can generate a suitable variant
of @{thm[source] small_step.induct} for pairs by ``splitting'' the arguments
\<open>\<rightarrow>\<close> into pairs:\<close>
lemmas small_step_induct = small_step.induct[split_format(complete)]


subsubsection\<open>Proof automation\<close>

declare small_step.intros[simp,intro]

text\<open>Rule inversion:\<close>

inductive_cases SkipE[elim!]: "(SKIP,s) \<rightarrow> ct"
inductive_cases AssignE[elim!]: "(x::=a,s) \<rightarrow> ct"
inductive_cases SeqE[elim]: "(c1;;c2,s) \<rightarrow> ct"
inductive_cases IfE[elim!]: "(IF b\<noteq>0 THEN c1 ELSE c2,s) \<rightarrow> ct"
inductive_cases WhileE[elim]: "(WHILE b\<noteq>0 DO c, s) \<rightarrow> ct"

subsection "Sequence properties"
declare rel_pow_intros[simp,intro]

text\<open>A simple property:\<close>
lemma deterministic:
  "cs \<rightarrow> cs' \<Longrightarrow> cs \<rightarrow> cs'' \<Longrightarrow> cs'' = cs'"
apply(induction arbitrary: cs'' rule: small_step.induct)
      apply blast+
  apply auto
done

text "sequence property"
lemma star_seq2: "(c1,s) \<rightarrow>\<^bsup>t\<^esup> (c1',s') \<Longrightarrow> (c1;;c2,s) \<rightarrow>\<^bsup> t \<^esup> (c1';;c2,s')"
proof(induction t arbitrary: c1 c1' s s')
  case (Suc t)
  then obtain c1'' s'' where "(c1,s) \<rightarrow> (c1'', s'')" 
                         and "(c1'', s'')  \<rightarrow>\<^bsup> t \<^esup>  (c1', s')" by auto
  moreover then have "(c1'';;c2, s'') \<rightarrow>\<^bsup> t \<^esup> (c1';;c2, s')" using Suc by simp
  ultimately show ?case by auto
qed auto
end