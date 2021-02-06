\<^marker>\<open>creator Florian Keßler\<close>

section "IMP- max constant"

theory IMP_Minus_Max_Constant 
  imports "../IMP-/Small_StepT" 
begin 

fun atomExp_to_constant:: "atomExp \<Rightarrow> nat" where
"atomExp_to_constant (V var) = 0" |
"atomExp_to_constant (N val) = val"

fun aexp_max_constant:: "AExp.aexp \<Rightarrow> nat" where
"aexp_max_constant (A a) = atomExp_to_constant a" |
"aexp_max_constant (Plus a b) = max (atomExp_to_constant a) (atomExp_to_constant b)" |
"aexp_max_constant (Sub a b) = max (atomExp_to_constant a) (atomExp_to_constant b)"

fun max_constant :: "com \<Rightarrow> nat" where
"max_constant (SKIP) = 0" |
"max_constant (Assign vname aexp) = aexp_max_constant aexp" |
"max_constant (Seq c1  c2) = max (max_constant c1) (max_constant c2)" |         
"max_constant (If  _ c1 c2) = max (max_constant c1) (max_constant c2)"  |   
"max_constant (While _ c) = max_constant c"

lemma Max_range_le_then_element_le: "finite (range s) \<Longrightarrow> 2 * Max (range s) < (x :: nat) \<Longrightarrow> 2 * (s y) < x" 
proof -
  assume "2 * Max (range s) < (x :: nat)"
  moreover have "s y \<in> range s" by simp
  moreover assume "finite (range s)" 
  moreover hence "s y \<le> Max (range s)" by simp
  ultimately show ?thesis by linarith
qed

lemma aval_le_when: 
  assumes "finite (range s)" "2 * max (Max (range s)) (aexp_max_constant a) < x" 
  shows "AExp.aval a s < x"
using assms proof(cases a)
  case (A x1)
  thus ?thesis using assms
  proof(cases x1)
    case (V x2)
    thus ?thesis using assms A Max_range_le_then_element_le[where ?s=s and ?x = x and ?y=x2] by simp
  qed simp
next
  case (Plus x21 x22)
  hence "2 * max (AExp.atomVal x21 s) (AExp.atomVal x22 s) < x" 
    apply(cases x21; cases x22)
    using assms 
    by (auto simp add: Max_range_le_then_element_le nat_mult_max_right)
  thus ?thesis using Plus by auto
next
  case (Sub x31 x32)
  then show ?thesis 
    apply(cases x31 ; cases x32)
    using assms apply(auto simp add: Max_range_le_then_element_le nat_mult_max_right)
    using Max_range_le_then_element_le 
    by (metis gr_implies_not0 lessI less_imp_diff_less less_imp_le_nat less_le_trans 
        linorder_neqE_nat n_less_m_mult_n numeral_2_eq_2)+
qed

fun atomExp_var:: "atomExp \<Rightarrow> vname list" where
"atomExp_var (V var) = [ var ]" |
"atomExp_var (N val) = []"

fun aexp_vars:: "AExp.aexp \<Rightarrow> vname list" where
"aexp_vars (A a) = atomExp_var a" |
"aexp_vars (Plus a b) = (atomExp_var a) @ (atomExp_var b)" |
"aexp_vars (Sub a b) = (atomExp_var a) @ (atomExp_var b)"

fun all_variables :: "com \<Rightarrow> vname list" where
"all_variables (SKIP) = []" |
"all_variables (Assign v aexp) = v # aexp_vars aexp" |
"all_variables (Seq c1 c2) = all_variables c1 @ all_variables c2" |
"all_variables (If v c1 c2) = [ v ] @ all_variables c1 @ all_variables c2" |
"all_variables (While v c) = [ v ] @ all_variables c"

definition num_variables:: "com \<Rightarrow> nat" where
"num_variables c = length (remdups (all_variables c))" 

end