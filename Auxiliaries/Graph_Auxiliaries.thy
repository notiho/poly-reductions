theory Graph_Auxiliaries
  imports Main  "Set_Auxiliaries" "List_Auxiliaries"
    Graph_Theory.Digraph  Graph_Theory.Arc_Walk
    Graph_Theory.Vertex_Walk
begin

section\<open>Graph Auxiliaries\<close>

lemma last_vwalk_arcs_last_p:
  assumes "snd (last (vwalk_arcs p)) = v" "(vwalk_arcs p) \<noteq> []"
  shows "last p = v"
  using assms
proof(induction p)
  case Nil
  then show ?case 
    by simp
next
  case (Cons a p)
  then show ?case 
  proof(cases "p = []")
    case True
    then have "vwalk_arcs (a#p) = []" 
      by simp
    then show ?thesis 
      using Cons 
      by auto
  next
    case False
    then have 1: "p\<noteq> []" 
      by simp
    then have 2: "vwalk_arcs (a#p) = (a, hd p)#vwalk_arcs p"
      using vwalk_arcs_Cons 
      by auto
    then have "vwalk_arcs (a#p) \<noteq> []" by auto
    then show ?thesis
    proof(cases "vwalk_arcs p = []")
      case True
      then have 3: "(last (vwalk_arcs (a#p))) = (a, hd p)"
        using 2 
        by simp 
      have "last p = hd p" using True 1 
        by (metis hd_rev list.distinct(1) list.exhaust rev_singleton_conv vwalk_arcs_Cons) 
      then show ?thesis 
        using 3 Cons False 
        by auto 
    next
      case False
      then have "snd (last (vwalk_arcs (a#p))) = snd (last (vwalk_arcs p))"
        by (simp add: 2) 
      then have "snd (last (vwalk_arcs p)) = v" 
        using Cons 
        by simp
      then have 3: "last p = v" 
        using Cons False 
        by simp 
      have "p \<noteq> []" 
        by (simp add: 1)
      then have "last (a#p) = last p" 
        by auto
      then show ?thesis 
        using 3 
        by simp 
    qed
  qed
qed


lemma hd_vwalk_arcs_last_p:
  assumes "fst (hd (vwalk_arcs p)) = v" "(vwalk_arcs p) \<noteq> []"
  shows "hd p = v"
  using assms
proof(induction p)
  case Nil
  then show ?case 
    by simp
next
  case (Cons a p)
  then show ?case 
  proof(cases "p = []")
    case True
    then have "vwalk_arcs (a#p) = []" 
      by simp
    then show ?thesis 
      using Cons 
      by auto
  next
    case False
    then have 1: "p\<noteq> []" 
      by simp
    then have 2: "vwalk_arcs (a#p) = (a, hd p)#vwalk_arcs p"
      using vwalk_arcs_Cons 
      by auto
    then have "fst (hd (vwalk_arcs (a#p))) = a"
      by simp
    then show ?thesis 
      using Cons 
      by simp 
  qed
qed


lemma vwalk_arcs_empty_length_p: 
  assumes "vwalk_arcs p = []"
  shows "length p \<le> 1" 
  using assms 
  apply(induction p) 
   apply(auto)
  using vwalk_arcs_Cons 
  by fastforce  


lemma length_C_vwalk_arcs_not_empty: 
  assumes "length C > 1"
  shows "vwalk_arcs C \<noteq> []"
  using assms vwalk_arcs_empty_length_p 
  by fastforce


lemma sublist_imp_in_arcs: 
  assumes "sublist [a, b] Cy" 
  shows "(a, b) \<in> set (vwalk_arcs Cy)"
  using assms 
  apply(induction Cy) 
   apply(auto simp add: sublist_def) 
  by (metis in_set_vwalk_arcs_append1 list.set_intros(1) vwalk_arcs.simps(3)) 


lemma vwalk_arcs_from_length_1: 
  assumes "length C = 1"
  shows "vwalk_arcs C = []"
  using assms 
  by (metis length_1_set_L list.set_intros(1) vwalk_arcs.simps(1) vwalk_arcs.simps(2) vwalk_to_vpath.cases) 


lemma at_least_to_nodes_vwalk_arcs_awalk_verts: 
  assumes "length C > 1" "head G' = snd" "tail G' = fst"
  shows "(pre_digraph.awalk_verts G' u (vwalk_arcs C)) = C"
  using assms 
proof(induction C arbitrary: u)
  case Nil
  then show ?case 
    by auto
next
  case (Cons a C)
  then have 1: "vwalk_arcs (a#C) = (a, hd C) # vwalk_arcs C"
    by auto
  then show ?case 
  proof(cases "length C > 1")
    case True
    then have 2: "pre_digraph.awalk_verts G' (hd C) (vwalk_arcs C) = C"
      using Cons 
      by simp
    have "pre_digraph.awalk_verts G' u (vwalk_arcs (a#C)) = 
      tail G' (a, hd C) # (pre_digraph.awalk_verts G' (head G' (a, hd C)) (vwalk_arcs C))" 
      using 1 
      by (simp add: pre_digraph.awalk_verts.simps(2)) 
    then have "pre_digraph.awalk_verts G' u (vwalk_arcs (a#C)) 
      = a # (pre_digraph.awalk_verts G' (head G' (a, hd C)) (vwalk_arcs C))"
      using assms
      by fastforce
    then have "pre_digraph.awalk_verts G' u (vwalk_arcs (a#C)) 
      = a # (pre_digraph.awalk_verts G' (hd C) (vwalk_arcs C))"
      using assms
      by fastforce
    then show ?thesis 
      using 2 
      by simp
  next
    case False
    then have lC: "length C = 1" 
      using Cons linorder_neqE_nat 
      by auto 
    then have hd_C: "C = [hd C]" 
      by (metis "1" list.sel(1) neq_Nil_conv vwalk_arcs.simps(2) vwalk_arcs_Cons vwalk_arcs_from_length_1) 
    then have "vwalk_arcs (a#C) = (a, hd C) #[]"
      using 1 lC vwalk_arcs_from_length_1 
      by auto 
    then have 2: "pre_digraph.awalk_verts G' u (vwalk_arcs (a#C)) = pre_digraph.awalk_verts G' u [(a, hd C)]"
      by argo
    then have 3: "... = (tail G' (a, hd C)) # (pre_digraph.awalk_verts G' (head G' (a, hd C)) [])"
      by (simp add: pre_digraph.awalk_verts.simps(2)) 
    then have 4: "... =  (tail G' (a, hd C)) # [(head G' (a, hd C))]"      
      by (simp add: pre_digraph.awalk_verts.simps) 
    then have 5: "... = a #  [(head G' (a, hd C))]" 
      using assms 
      by fastforce
    then have 6: "... = a # [(hd C)]"
      using assms 
      by auto
    then show ?thesis 
      using assms 2 3 4 5 6 hd_C 
      by argo  
  qed
qed 


lemma arc_to_ends_G': 
  assumes "head G' = snd" "tail G' = fst" 
  shows "arc_to_ends G' e = e"
  using arc_to_ends_def assms
  by (simp add: arc_to_ends_def) 


lemma arcs_ends_G':  
  assumes "head G' = snd" "tail G' = fst" 
  shows "arcs_ends G' = arcs G'"
  using arcs_ends_def arc_to_ends_G' assms
  by(auto simp add: arcs_ends_def arc_to_ends_G')


lemma if_edge_then_cycle_length_geq_2:
  assumes "(u, v) \<in> set (vwalk_arcs C)" 
  shows "length C \<ge> 2"
proof(rule ccontr)
  assume "\<not> 2 \<le> length C"
  then have length_C: "length C = 1 \<or> length C = 0" 
    by linarith
  then show False 
  proof(cases "length C = 1")
    case True
    then have "vwalk_arcs C = []" 
      by (metis One_nat_def Suc_length_conv length_0_conv vwalk_arcs.simps(2))
    then show ?thesis
      using assms 
      by auto
  next
    case False
    then have "length C = 0" 
      using length_C 
      by auto
    then have "vwalk_arcs C = []" 
      by auto
    then show ?thesis 
      using assms 
      by auto
  qed
qed


lemma sublist_for_edges: 
  assumes "(u, v) \<in> set (vwalk_arcs C)"
  shows "sublist [u, v] C"
  using assms 
proof(induction C)
  case Nil
  then show ?case 
    by auto
next
  case (Cons a C)
  then have length_C: "length C \<ge> 1" 
    using if_edge_then_cycle_length_geq_2 
    by fastforce
  then show ?case proof(cases "u = a \<and> v = hd C")
    case True
    then have "[]@[u,v] @ (tl C) = (a#C)" 
      by (metis Cons.prems append_Cons append_self_conv2 list.collapse list.distinct(1) list.set_cases vwalk_arcs.simps(2))
    then show ?thesis 
      using sublist_def
      by blast
  next
    case False
    then have "(u,v) \<in> set (vwalk_arcs C)" 
      using Cons 
      by (metis prod.inject set_ConsD vwalk_arcs.simps(1) vwalk_arcs.simps(2) vwalk_arcs_Cons) 
    then have "\<exists>p1 p2. p1 @ [u, v] @ p2 = C" 
      using Cons 
      unfolding sublist_def 
      by auto
    then obtain p1 p2 where p_def: "p1 @ [u, v] @ p2 = C"
      by blast
    then obtain p1' where "p1' = a # p1" 
      by auto
    then have "p1' @ [u, v] @ p2 = (a#C)" 
      using p_def 
      by auto
    then show ?thesis
      using Cons sublist_def
      by blast
  qed
qed


lemma if_sublist_then_edge: 
  assumes "sublist [u, v] C"
  shows "(u, v) \<in> set (vwalk_arcs C)"
  using assms sublist_imp_in_arcs 
  by fast


lemma in_sublist_impl_in_list:
  assumes "sublist a b" "x \<in> set a"
  shows "x \<in> set b"
  using assms 
  by (metis append_Cons append_assoc in_set_conv_decomp sublist_def) 


end