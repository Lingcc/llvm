; RUN: llc < %s -march=x86 -mattr=+sse2,+ssse3 | FileCheck %s
; There are no MMX operations in @t1

define void  @t1(i32 %a, x86_mmx* %P) nounwind {
; CHECK-LABEL: t1:
; CHECK:       # BB#0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    shll $12, %ecx
; CHECK-NEXT:    movd %ecx, %xmm0
; CHECK-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,0,0,1]
; CHECK-NEXT:    movlpd %xmm0, (%eax)
; CHECK-NEXT:    retl
 %tmp12 = shl i32 %a, 12
 %tmp21 = insertelement <2 x i32> undef, i32 %tmp12, i32 1
 %tmp22 = insertelement <2 x i32> %tmp21, i32 0, i32 0
 %tmp23 = bitcast <2 x i32> %tmp22 to x86_mmx
 store x86_mmx %tmp23, x86_mmx* %P
 ret void
}

define <4 x float> @t2(<4 x float>* %P) nounwind {
; CHECK-LABEL: t2:
; CHECK:       # BB#0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movaps (%eax), %xmm1
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0],xmm0[2,0]
; CHECK-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,0]
; CHECK-NEXT:    retl
  %tmp1 = load <4 x float>, <4 x float>* %P
  %tmp2 = shufflevector <4 x float> %tmp1, <4 x float> zeroinitializer, <4 x i32> < i32 4, i32 4, i32 4, i32 0 >
  ret <4 x float> %tmp2
}

define <4 x float> @t3(<4 x float>* %P) nounwind {
; CHECK-LABEL: t3:
; CHECK:       # BB#0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movapd (%eax), %xmm0
; CHECK-NEXT:    xorpd %xmm1, %xmm1
; CHECK-NEXT:    unpckhpd {{.*#+}} xmm0 = xmm0[1],xmm1[1]
; CHECK-NEXT:    retl
  %tmp1 = load <4 x float>, <4 x float>* %P
  %tmp2 = shufflevector <4 x float> %tmp1, <4 x float> zeroinitializer, <4 x i32> < i32 2, i32 3, i32 4, i32 4 >
  ret <4 x float> %tmp2
}

define <4 x float> @t4(<4 x float>* %P) nounwind {
; CHECK-LABEL: t4:
; CHECK:       # BB#0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movaps (%eax), %xmm0
; CHECK-NEXT:    xorps %xmm1, %xmm1
; CHECK-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,0],xmm1[1,0]
; CHECK-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,2],xmm1[2,3]
; CHECK-NEXT:    retl
  %tmp1 = load <4 x float>, <4 x float>* %P
  %tmp2 = shufflevector <4 x float> zeroinitializer, <4 x float> %tmp1, <4 x i32> < i32 7, i32 0, i32 0, i32 0 >
  ret <4 x float> %tmp2
}

define <16 x i8> @t5(<16 x i8> %x) nounwind {
; CHECK-LABEL: t5:
; CHECK:       # BB#0:
; CHECK-NEXT:    psrlw $8, %xmm0
; CHECK-NEXT:    retl
  %s = shufflevector <16 x i8> %x, <16 x i8> zeroinitializer, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 17>
  ret <16 x i8> %s
}

define <16 x i8> @t6(<16 x i8> %x) nounwind {
; CHECK-LABEL: t6:
; CHECK:       # BB#0:
; CHECK-NEXT:    psrlw $8, %xmm0
; CHECK-NEXT:    retl
  %s = shufflevector <16 x i8> %x, <16 x i8> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  ret <16 x i8> %s
}

define <16 x i8> @t7(<16 x i8> %x) nounwind {
; CHECK-LABEL: t7:
; CHECK:       # BB#0:
; CHECK-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0,1,2]
; CHECK-NEXT:    retl
  %s = shufflevector <16 x i8> %x, <16 x i8> undef, <16 x i32> <i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 1, i32 2>
  ret <16 x i8> %s
}

define <16 x i8> @t8(<16 x i8> %x) nounwind {
; CHECK-LABEL: t8:
; CHECK:       # BB#0:
; CHECK-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero
; CHECK-NEXT:    retl
  %s = shufflevector <16 x i8> %x, <16 x i8> zeroinitializer, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 8, i32 9, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 17>
  ret <16 x i8> %s
}

define <16 x i8> @t9(<16 x i8> %x) nounwind {
; CHECK-LABEL: t9:
; CHECK:       # BB#0:
; CHECK-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero
; CHECK-NEXT:    retl
  %s = shufflevector <16 x i8> %x, <16 x i8> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 7, i32 8, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 14, i32 undef, i32 undef>
  ret <16 x i8> %s
}
