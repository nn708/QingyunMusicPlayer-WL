(* ::Package:: *)

(* Box Tools *)
BoxApply[StyleBox[boxspec__], options___] := StyleBox[boxspec, options];
BoxApply[RowBox[boxes_List], options___] := RowBox[BoxApply[#, options]& /@ boxes];
BoxSimplify[StyleBox[box_StyleBox, options___]] := Insert[box, Unevaluated[options], 2];
BoxSimplify[StyleBox[box_RowBox, options___]] := StyleBox[BoxSimplify[box], options];
BoxSimplify[RowBox[boxes_List]] := BoxSimplify[boxes];
BoxSimplify[boxes_List] := If[Length[boxes] == 1, boxes[[1]],
	RowBox @ ReplaceRepeated[boxes, {
		{pre___, PatternSequence[
			StyleBox[str1_String, options___],
			StyleBox[str2_String, options___]
		], post___} :> {pre, StyleBox[str1 <> str2, options], post},
		RowBox[boxes1_List] :> BoxSimplify[boxes1]
	}]
];

(* Render Syntax *)
RenderText[line_String, style_String] := Block[{output},
	output = StringCases[line, {
		"(("~~text:Except[")"]..~~"))" :>
			BoxApply[RenderText[text, style], Smaller, FontColor -> RGBColor["#555555"]],
		"**"~~text:Except["*"]..~~"**" :>
			BoxApply[RenderText[text, style], FontWeight -> Bold],
		"*"~~text:Except["*"]..~~"*" :>
			BoxApply[RenderText[text, style], FontSlant -> Italic],
		"~~"~~text:Except["~"]..~~"~~" :>
			BoxApply[RenderText[text, style], FontVariations -> {"StrikeThrough" -> True}],
		"_"~~text:Except["_"]..~~"_" :>
			BoxApply[RenderText[text, style], FontVariations -> {"Underline" -> True}],
		text_ :> RowBox @ StringCases[text, {
			text1__?(PrintableASCIIQ) :> StyleBox[text1, style],
			text1__?(Not@*PrintableASCIIQ) :> StyleBox[text1, style <> "-chs"]
		}]
	}];
	Return[BoxSimplify @ RowBox @ output];
];

(* Spacer Cell *)
Options[SpacerCell] = {
	CellFrameColor -> Automatic,
	Background -> Inherited
};
SpacerCell[h_Integer, op:OptionsPattern[]] := SpacerCell[0, h, 0, op];
SpacerCell[w_Integer, h_Integer, op:OptionsPattern[]] := SpacerCell[w, h, 0, op];
SpacerCell[w_Integer, h_Integer, t_Integer, OptionsPattern[]] := Cell["", "Text",
	CellSize -> {Inherited, 1},
	CellMargins -> {{w, w}, {h, h}},
	CellElementSpacings -> {"CellMinHeight" -> 1},
	CellFrame -> If[t >= 0, {{0, 0}, {0, t}}, {{0, 0}, {-t, 0}}],
	CellFrameColor -> OptionValue[CellFrameColor],
	CellFrameMargins -> 0, 
	Background -> OptionValue[Background],
	Selectable -> False
];

(* Main *)
RenderContent[rawData_List] := Block[
	{
		line, lineCount, lineNext,
		markCount, markCount1,
		$tmpID, $tmpTag
	},
	
	$tmpTag := "tmpCell" <> ToString[$tmpID];
	lineCount = 1;
	
	Return @ Flatten[Reap[
		While[lineCount <= Length[rawData],
			line = rawData[[lineCount]];
			lineCount += 1;
			Which[
				
				(* Separator *)
				StringMatchQ[line, RegularExpression["\\-{3,} *"]],
					Sow[SpacerCell[40, 1, 2, CellFrameColor -> RGBColor["#777777"]], "Cell"],
				StringMatchQ[line, RegularExpression["={3,} *"]],
					Sow[SpacerCell[40, 2, 4, CellFrameColor -> RGBColor["#999999"]], "Cell"],
					
				(* Title *)
				StringStartsQ[line, RegularExpression["#"]],
					markCount = StringLength @ StringCases[line, RegularExpression["^#+"]][[1]];
					Sow[Cell[
						BoxData @ RenderText[StringDelete[line, RegularExpression["^#+ *| *#*$"]], "Title"],
						CellMargins -> {{72, 72}, {20, 40}},
						FontSize -> 72 - markCount * 12,
						FontColor -> RGBColor["#111111"],
						TextAlignment -> If[StringEndsQ[line, RegularExpression["# *"]], Center, Left]
					], "Cell"],
				
				(* Usage *)
				StringStartsQ[line, RegularExpression["\\-*\\?"]],
					Sow[Cell[CellGroupData[{
						SpacerCell[0, 0, -2, CellFrameColor -> RGBColor["#77BBFF"]],
						Sequence @@ (Cell[BoxData[RowBox[#]],
							CellMargins -> {{0, 0}, {0, 0}},
							CellFrame -> {{0, 0}, {1, 1}},
							CellFrameColor -> RGBColor["#77BBFF"],
							Background -> RGBColor["#DDEEFF"],
							LineSpacing -> {1.5, 0}
						]&/@ Reap[
							$tmpID = 0;
							lineCount -= 1;
							While[lineCount <= Length[rawData] && StringStartsQ[line, RegularExpression["-*\\?"]],
								markCount = StringLength @ StringCases[line, RegularExpression["^-*"]][[1]];
								If[markCount == 0, $tmpID += 1, Sow["\n", $tmpTag]];
								Sow[TemplateBox[{48 + markCount * 24}, "Spacer1"], $tmpTag];
								Sow[RenderText[StringDelete[line, RegularExpression["^-*\\? *"]], "Usage"], $tmpTag];
								lineCount += 1;
								line = rawData[[lineCount]];
							];
						][[-1]]),
						SpacerCell[0, 0, 2, CellFrameColor -> RGBColor["#77BBFF"]]
					}]], "Cell"],
				
				(* Section *)
				StringStartsQ[line, RegularExpression["\\-*\\^+"]],
					markCount = StringLength @ StringCases[line, RegularExpression["^\\-*\\^+"]][[1]];
					markCount1 = StringLength @ StringCases[line, RegularExpression["^\\-*"]][[1]];
					lineNext = lineCount + LengthWhile[rawData[[lineCount ;; ]], Nor[
						StringStartsQ[#, Repeated["#", markCount]],
						And[
							StringStartsQ[#, RegularExpression["\\-*\\^+"]],
							StringLength @ StringCases[#, RegularExpression["^\\-*\\^+"]][[1]] <= markCount
						],
						StringMatchQ[#, RegularExpression["={3,} *"]]
					]&];
					Sow[Cell[CellGroupData[{
						Cell[
							RenderText[StringDelete[line, RegularExpression["^\\-*\\^+ *"]], "Section"],
							ShowGroupOpener -> True,
							CellMargins -> {{48, 48} + markCount * 12, {10, 18}},
							FontSize -> 48 - (markCount - markCount1) * 12
						],
						Sequence @@ RenderContent[rawData[[lineCount ;; lineNext - 1]]]
					}]], "Cell"];
					lineCount = lineNext,
				
				(* Text *)
				!StringMatchQ[line, RegularExpression["\\s*"]],
					Sow[Cell[BoxData[RenderText[line, "Text"]], "Text"], "Cell"];
				
			];
		],
	"Cell"][[-1]], 1];
];

(* API *)
RenderTMD::nfound = "Cannot find file `1`.";
RenderTMD::usage = "\
\!\(\*RowBox[{\"RenderTMD\",\"[\",RowBox[{StyleBox[\"filepath\",\"TI\"]}],\"]\"}]\)
generate a document notebook for \!\(\*StyleBox[\"filepath\",\"TI\"]\).";

RenderTMD[filepath_String] := Block[
	{
		rawData
	},
	
	If[FileExistsQ[filepath],
		rawData = StringSplit[Import[filepath, "Text", CharacterEncoding -> "UTF-8"], "\n"],
		Message[RenderTMD::nfound, filepath];
		Return[];
	];
	
	CreateDialog[RenderContent[rawData],
		WindowTitle -> StringSplit[filepath,"/"|"\\"][[-1]],
		WindowMargins -> {{80, Automatic}, {Automatic, 60}},
		WindowElements -> {"VerticalScrollBar"},
		Background -> RGBColor["#F7F7F7"],
		WindowSize -> {1024, 768},
		ClosingSaveDialog -> False,
		StyleDefinitions -> StyleSheet["Documemt"],
		ShowCellBracket -> False,
		CellGrouping -> Manual,
		Saveable -> False,
		Editable -> False,
		Copyable -> False,
		Enabled -> False
	];
];



(* ::Input:: *)
(*RenderTMD[localPath<>"docs/test.tmd"];*)
