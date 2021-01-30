\<^marker>\<open>creator Bilel Ghorbel, Florian Kessler\<close>

section "Small step semantics of IMP- "

subsection "Small step semantics definition"
theory IMP_Minus_Minus_Small_StepT  imports Main IMP_Minus_Minus_Com "../IMP-/Rel_Pow" begin

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


fun small_step_fun:: "com * state \<Rightarrow> com * state" where
"small_step_fun (SKIP, s) = (SKIP, s)" |
"small_step_fun (x ::= a, s) = (SKIP, s(x := aval a s))" |
"small_step_fun (c\<^sub>1;;c\<^sub>2,s) = (if c\<^sub>1 = SKIP then (c\<^sub>2,s) 
  else  (fst (small_step_fun (c\<^sub>1, s)) ;;c\<^sub>2, snd (small_step_fun (c\<^sub>1, s))))" |
"small_step_fun (IF b \<noteq>0 THEN c\<^sub>1 ELSE c\<^sub>2,s) = (if s b \<noteq> 0 then (c\<^sub>1,s) else (c\<^sub>2,s))" |
"small_step_fun (WHILE b\<noteq>0 DO c,s) = (if s b \<noteq> 0 then (c ;; (WHILE b \<noteq>0 DO c), s) else (SKIP,s))" 

fun t_small_step_fun:: "nat \<Rightarrow> com * state \<Rightarrow> com * state" where
"t_small_step_fun 0 = id" |
"t_small_step_fun (Suc t) = (t_small_step_fun t) \<circ> small_step_fun" 

lemma t_small_step_fun_ge_0: "t > 0 
  \<Longrightarrow> t_small_step_fun t (c, s) = t_small_step_fun (t - 1) (small_step_fun (c, s))" 
proof-
  assume "t > 0"
  then obtain t' where "t = Suc t'" using lessE by blast
  thus ?thesis by simp
qed

lemma t_small_step_fun_small_step_fun: "t_small_step_fun t (small_step_fun cs) 
  = t_small_step_fun (t + 1) cs" 
  by simp

lemma small_step_fun_t_small_step_fun: "small_step_fun (t_small_step_fun t (c, s))
  = t_small_step_fun (t + 1) (c, s)"
proof(induction t arbitrary: c s)
  case (Suc t)
  let ?c' = "fst (small_step_fun (c, s))" 
  let ?s' = "snd (small_step_fun (c, s))"
  have "small_step_fun (t_small_step_fun t (?c', ?s')) = t_small_step_fun t (small_step_fun (?c', ?s'))" 
    using Suc t_small_step_fun_small_step_fun by presburger
  thus ?case by auto
qed auto

lemma t_small_step_fun_SKIP[simp]: "t_small_step_fun t (SKIP, s) = (SKIP, s)" 
  apply(induction t) 
  by auto

lemma t_small_step_fun_terminate_iff: "t_small_step_fun t (c1, s1) = (SKIP, s2) \<longleftrightarrow>
  ((c1 = SKIP \<and> s1 = s2) \<or> (t > 0 \<and> t_small_step_fun (t - 1) (small_step_fun (c1, s1)) 
    = (SKIP, s2)))" 
  apply(auto simp: t_small_step_fun_ge_0)
   apply (metis One_nat_def id_apply less_Suc_eq_0_disj prod.inject t_small_step_fun.elims t_small_step_fun_ge_0)
  by (metis One_nat_def Pair_inject id_apply less_Suc_eq_0_disj t_small_step_fun.elims t_small_step_fun_ge_0)

lemma t_small_step_fun_decomposition: "t_small_step_fun (a + b) cs 
  = t_small_step_fun a (t_small_step_fun b cs)" 
  apply(induction a arbitrary: cs)
  by(auto simp: small_step_fun_t_small_step_fun)

lemma t_small_step_fun_increase_time: "t \<le> t' \<Longrightarrow> t_small_step_fun t (c1, s1) = (SKIP, s2) 
  \<Longrightarrow> t_small_step_fun t' (c1, s1) = (SKIP, s2)" 
  using t_small_step_fun_decomposition[where ?a="t' - t" and ?b="t"] by simp

lemma exists_terminating_iff: "(\<exists>t < Suc t'. 
  t_small_step_fun t (c, s) = (SKIP, s'))
  \<longleftrightarrow>  t_small_step_fun t' (c, s) = (SKIP, s')" 
  using t_small_step_fun_increase_time by (auto simp: less_Suc_eq_le)

lemma terminates_then_can_reach_SKIP_in_seq: "t_small_step_fun t (c1, s1) = (SKIP, s2) 
  \<Longrightarrow> (\<exists>t' \<le> t. t_small_step_fun t' (c1 ;; c2, s1) = (SKIP ;; c2, s2))"
proof(induction t arbitrary: c1 s1)
  case (Suc t)
  have "c1 = SKIP \<or> c1 \<noteq> SKIP" by auto
  thus ?case using Suc
  proof (elim disjE)
    assume *: "c1 \<noteq> SKIP"
    let ?c1' = "fst (small_step_fun (c1, s1))" 
    let ?s1' = "snd (small_step_fun (c1, s1))"
    have "t_small_step_fun t (?c1', ?s1') = (SKIP, s2)" using *
      by (metis Suc.prems Suc_eq_plus1 prod.collapse t_small_step_fun_small_step_fun)
    then obtain t' where "t' \<le> t \<and> t_small_step_fun t' (?c1' ;; c2, ?s1') = (SKIP ;; c2, s2)"
      using Suc by blast
    thus ?case using * by auto
  qed auto
qed auto

lemma seq_terminates_iff: "t_small_step_fun t (a ;; b, s1) = (SKIP, s2) \<longleftrightarrow>
  (\<exists>t' s3. t' < t \<and> t_small_step_fun t' (a, s1) = (SKIP, s3) 
  \<and> t_small_step_fun (t - (t' + 1)) (b, s3) = (SKIP, s2))"
proof(induction t arbitrary: a s1)
  case (Suc t)
  show ?case
  proof
    assume *: "t_small_step_fun (Suc t) (a;; b, s1) = (SKIP, s2)"
    have "a = SKIP \<or> a \<noteq> SKIP" by auto
    thus "\<exists>t' s3. t' < Suc t \<and> t_small_step_fun t' (a, s1) = (SKIP, s3) 
        \<and> t_small_step_fun (Suc t - (t' + 1)) (b, s3) = (SKIP, s2)"
    using * proof (elim disjE)
      assume **: "a \<noteq> SKIP" 
      let ?a' = "fst (small_step_fun (a, s1))" 
      let ?s1' = "snd (small_step_fun (a, s1))"
      have "t_small_step_fun t (?a' ;; b, ?s1') = (SKIP, s2)" using * ** 
        by (auto simp: t_small_step_fun_terminate_iff) 
      then obtain t' s3 where "t' < t \<and> t_small_step_fun t' (?a', ?s1') = (SKIP, s3) 
        \<and> t_small_step_fun (t - (t' + 1)) (b, s3) = (SKIP, s2)" using Suc by auto
      hence "t' + 1 < t + 1 \<and> t_small_step_fun (t' + 1) (a, s1) = (SKIP, s3)
        \<and> t_small_step_fun (t - (t' + 1)) (b, s3) = (SKIP, s2)" by(auto)
      thus ?thesis by auto
    qed auto
  next
    assume "\<exists>t' s3. t' < Suc t \<and> t_small_step_fun t' (a, s1) = (SKIP, s3) 
      \<and> t_small_step_fun (Suc t - (t' + 1)) (b, s3) = (SKIP, s2)"
    then obtain t' s3 where t'_def: "t' < Suc t \<and> t_small_step_fun t' (a, s1) = (SKIP, s3) 
      \<and> t_small_step_fun (Suc t - (t' + 1)) (b, s3) = (SKIP, s2)" by blast
    then obtain t'' where t''_def: "t'' \<le> t' \<and> t_small_step_fun t'' (a ;; b, s1) = (SKIP ;; b, s3)"
      using terminates_then_can_reach_SKIP_in_seq by blast
    hence "t_small_step_fun (t'' + ((Suc t - (t' + 1)) + 1)) (a ;; b, s1) 
      = t_small_step_fun (Suc t - (t' + 1) + 1) (SKIP ;; b, s3)" 
      using t_small_step_fun_decomposition[where ?b="t''"] t'_def by (metis add.commute)
    also have "... = t_small_step_fun (Suc t  - (t' + 1)) (b, s3)" using t'_def 
      by(auto simp: t_small_step_fun_ge_0)
    also have "... = (SKIP, s2)" using t'_def by simp
    ultimately show "t_small_step_fun (Suc t) (a ;; b, s1) = (SKIP, s2)" 
      apply -
      apply(rule t_small_step_fun_increase_time[where ?t="t'' + ((Suc t - (t' + 1)) + 1)"])
      using t'_def t''_def by(auto)
  qed
qed auto

lemma seq_terminates_when: "t1 + t2 < t \<Longrightarrow> t_small_step_fun t1 (a, s1) = (SKIP, s3)
  \<Longrightarrow> t_small_step_fun t2 (b, s3) = (SKIP, s2)
  \<Longrightarrow> t_small_step_fun t (a ;; b, s1) = (SKIP, s2)" 
  apply(auto simp: seq_terminates_iff)
  by (metis Nat.add_diff_assoc2 add_lessD1 diff_Suc_Suc diff_add_inverse le_add_same_cancel1 
      less_natE t_small_step_fun_increase_time zero_le)
   
  
end