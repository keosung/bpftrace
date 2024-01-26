; ModuleID = 'bpftrace'
source_filename = "bpftrace"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf-pc-linux"

%"struct map_t" = type { i8*, i8* }
%"struct map_t.0" = type { i8*, i8*, i8*, i8* }
%printf_t = type { i64 }

@ringbuf = dso_local global %"struct map_t" zeroinitializer, section ".maps", !dbg !0
@ringbuf_loss_counter = dso_local global %"struct map_t.0" zeroinitializer, section ".maps", !dbg !16

; Function Attrs: nounwind
declare i64 @llvm.bpf.pseudo(i64 %0, i64 %1) #0

define i64 @"kprobe:f"(i8* %0) section "s_kprobe:f_1" !dbg !40 {
entry:
  %key = alloca i32, align 4
  %printf_args = alloca %printf_t, align 8
  %get_pid_tgid = call i64 inttoptr (i64 14 to i64 ()*)()
  %1 = lshr i64 %get_pid_tgid, 32
  %2 = icmp ugt i64 %1, 10000
  %3 = zext i1 %2 to i64
  %true_cond = icmp ne i64 %3, 0
  br i1 %true_cond, label %if_body, label %if_end

if_body:                                          ; preds = %entry
  %get_pid_tgid3 = call i64 inttoptr (i64 14 to i64 ()*)()
  %4 = lshr i64 %get_pid_tgid3, 32
  %5 = urem i64 %4, 2
  %6 = icmp eq i64 %5, 0
  %7 = zext i1 %6 to i64
  %true_cond4 = icmp ne i64 %7, 0
  br i1 %true_cond4, label %if_body1, label %if_end2

if_end:                                           ; preds = %if_end2, %entry
  ret i64 0

if_body1:                                         ; preds = %if_body
  %8 = bitcast %printf_t* %printf_args to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %8)
  %9 = bitcast %printf_t* %printf_args to i8*
  call void @llvm.memset.p0i8.i64(i8* align 1 %9, i8 0, i64 8, i1 false)
  %10 = getelementptr %printf_t, %printf_t* %printf_args, i32 0, i32 0
  store i64 0, i64* %10, align 8
  %ringbuf_output = call i64 inttoptr (i64 130 to i64 (%"struct map_t"*, %printf_t*, i64, i64)*)(%"struct map_t"* @ringbuf, %printf_t* %printf_args, i64 8, i64 0)
  %ringbuf_loss = icmp slt i64 %ringbuf_output, 0
  br i1 %ringbuf_loss, label %event_loss_counter, label %counter_merge

if_end2:                                          ; preds = %counter_merge, %if_body
  br label %if_end

event_loss_counter:                               ; preds = %if_body1
  %11 = bitcast i32* %key to i8*
  call void @llvm.lifetime.start.p0i8(i64 -1, i8* %11)
  store i32 0, i32* %key, align 4
  %lookup_elem = call i8* inttoptr (i64 1 to i8* (%"struct map_t.0"*, i32*)*)(%"struct map_t.0"* @ringbuf_loss_counter, i32* %key)
  %map_lookup_cond = icmp ne i8* %lookup_elem, null
  br i1 %map_lookup_cond, label %lookup_success, label %lookup_failure

counter_merge:                                    ; preds = %lookup_merge, %if_body1
  %12 = bitcast %printf_t* %printf_args to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %12)
  br label %if_end2

lookup_success:                                   ; preds = %event_loss_counter
  %13 = bitcast i8* %lookup_elem to i64*
  %14 = atomicrmw add i64* %13, i64 1 seq_cst
  br label %lookup_merge

lookup_failure:                                   ; preds = %event_loss_counter
  br label %lookup_merge

lookup_merge:                                     ; preds = %lookup_failure, %lookup_success
  %15 = bitcast i32* %key to i8*
  call void @llvm.lifetime.end.p0i8(i64 -1, i8* %15)
  br label %counter_merge
}

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg %0, i8* nocapture %1) #1

; Function Attrs: argmemonly nofree nosync nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly %0, i8 %1, i64 %2, i1 immarg %3) #2

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg %0, i8* nocapture %1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { argmemonly nofree nosync nounwind willreturn writeonly }

!llvm.dbg.cu = !{!36}
!llvm.module.flags = !{!39}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "ringbuf", linkageName: "global", scope: !2, file: !2, type: !3, isLocal: false, isDefinition: true)
!2 = !DIFile(filename: "bpftrace.bpf.o", directory: ".")
!3 = !DICompositeType(tag: DW_TAG_structure_type, scope: !2, file: !2, size: 128, elements: !4)
!4 = !{!5, !11}
!5 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !2, file: !2, baseType: !6, size: 64)
!6 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !7, size: 64)
!7 = !DICompositeType(tag: DW_TAG_array_type, baseType: !8, size: 864, elements: !9)
!8 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!9 = !{!10}
!10 = !DISubrange(count: 27, lowerBound: 0)
!11 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !2, file: !2, baseType: !12, size: 64, offset: 64)
!12 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !13, size: 64)
!13 = !DICompositeType(tag: DW_TAG_array_type, baseType: !8, size: 8388608, elements: !14)
!14 = !{!15}
!15 = !DISubrange(count: 262144, lowerBound: 0)
!16 = !DIGlobalVariableExpression(var: !17, expr: !DIExpression())
!17 = distinct !DIGlobalVariable(name: "ringbuf_loss_counter", linkageName: "global", scope: !2, file: !2, type: !18, isLocal: false, isDefinition: true)
!18 = !DICompositeType(tag: DW_TAG_structure_type, scope: !2, file: !2, size: 256, elements: !19)
!19 = !{!20, !25, !30, !33}
!20 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !2, file: !2, baseType: !21, size: 64)
!21 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !22, size: 64)
!22 = !DICompositeType(tag: DW_TAG_array_type, baseType: !8, size: 64, elements: !23)
!23 = !{!24}
!24 = !DISubrange(count: 2, lowerBound: 0)
!25 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !2, file: !2, baseType: !26, size: 64, offset: 64)
!26 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !27, size: 64)
!27 = !DICompositeType(tag: DW_TAG_array_type, baseType: !8, size: 32, elements: !28)
!28 = !{!29}
!29 = !DISubrange(count: 1, lowerBound: 0)
!30 = !DIDerivedType(tag: DW_TAG_member, name: "key", scope: !2, file: !2, baseType: !31, size: 64, offset: 128)
!31 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !32, size: 64)
!32 = !DIBasicType(name: "int32", size: 32, encoding: DW_ATE_signed)
!33 = !DIDerivedType(tag: DW_TAG_member, name: "value", scope: !2, file: !2, baseType: !34, size: 64, offset: 192)
!34 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !35, size: 64)
!35 = !DIBasicType(name: "int64", size: 64, encoding: DW_ATE_signed)
!36 = distinct !DICompileUnit(language: DW_LANG_C, file: !2, producer: "bpftrace", isOptimized: false, runtimeVersion: 0, emissionKind: LineTablesOnly, enums: !37, globals: !38)
!37 = !{}
!38 = !{!0, !16}
!39 = !{i32 2, !"Debug Info Version", i32 3}
!40 = distinct !DISubprogram(name: "kprobe_f", linkageName: "kprobe_f", scope: !2, file: !2, type: !41, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !36, retainedNodes: !45)
!41 = !DISubroutineType(types: !42)
!42 = !{!35, !43}
!43 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !44, size: 64)
!44 = !DIBasicType(name: "int8", size: 8, encoding: DW_ATE_signed)
!45 = !{!46, !47}
!46 = !DILocalVariable(name: "var0", scope: !40, file: !2, type: !35)
!47 = !DILocalVariable(name: "var1", arg: 1, scope: !40, file: !2, type: !43)
