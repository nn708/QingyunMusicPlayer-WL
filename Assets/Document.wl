(* ::Package:: *)

StyleSheet["Documemt"] = Notebook[{
	
	Cell[StyleData["Title"],
		FontFamily -> "Source Sans Pro Semibold",
		FontWeight -> "DemiBold"
	],
	Cell[StyleData["Title-chs"],
		FontFamily -> "\:9ed1\:4f53",
		FontWeight -> Plain
	],
	
	Cell[StyleData["Usage"],
		Background -> RGBColor["#DDEEFF"],
		FontFamily -> "Cambria",
		FontSize -> 24
	],
	Cell[StyleData["Usage-chs"],
		FontFamily -> "\:534e\:6587\:65b0\:9b4f",
		FontSize -> 24
	],
	
	Cell[StyleData["Text"],
		FontFamily -> "Calibri",
		FontSize -> 24
	],
	Cell[StyleData["Text-chs"],
		CellMargins -> {{48, 15}, {4, 8}},
		FontFamily -> "Calibri",
		FontSize -> 24
	],
	
	Cell[StyleData["Section"],
		FontFamily -> "Corbel",
		FontSize -> 32,
		FontColor -> RGBColor["#772200"]
	],
	Cell[StyleData["Section-chs"],
		FontFamily -> "\:5e7c\:5706",
		FontSize -> 32,
		FontColor -> RGBColor["#772200"]
	],
	
	Cell[StyleData["DingBat"],
		TemplateBoxOptions -> {
			DisplayFunction -> (AdjustmentBox[
				StyleBox[#,
					FontFamily -> "Source Sans Pro",
					FontSize -> 20,
					FontColor -> RGBColor["#777777"]
				],
				BoxBaselineShift -> -0.3
			]&)
		}
	],
	
	Cell[StyleData["Miniplayer"],
		TemplateBoxOptions -> {DisplayFunction -> (GraphicsBox[
			{
				RGBColor[0.92, 0.92, 0.92],
				RectangleBox[{0, 0}, {600, 48}, RoundingRadius -> 16],
				InsetBox[GraphicsBox[
					{
						RGBColor[0.96, 0.96, 0.96],
						RectangleBox[{0, 0}, {400, 32}, RoundingRadius -> 8]
					},
					ImageSize -> 400,
					PlotRange -> {{0, 400}, {0, 32}}
				], {8, Center}, {Left, Center}],
				InsetBox[AdjustmentBox[
					StyleBox[#1,
						FontSize -> 20,
						FontColor -> RGBColor[0, 0, 0]
					],
					BoxBaselineShift -> 0.1
				], {20, Center}, {Left, Center}]
			},
			ContentSelectable -> False,
			ImageSize -> 600,
			PlotRange -> {{0, 600}, {0, 48}}
		]&)}
	],
	
	Cell[StyleData["Multi-Code"],
		TemplateBoxOptions -> {DisplayFunction -> (GraphicsBox[
			{
				RGBColor[0.92, 0.92, 0.92],
				RectangleBox[{0, 0}, {600, 48}, RoundingRadius -> 16],
				InsetBox[GraphicsBox[
					{
						RGBColor[0.96, 0.96, 0.96],
						RectangleBox[{0, 0}, {400, 32}, RoundingRadius -> 8]
					},
					ImageSize -> 400,
					PlotRange -> {{0, 400}, {0, 32}}
				], {8, Center}, {Left, Center}],
				InsetBox[AdjustmentBox[
					StyleBox[#1,
						FontSize -> 20,
						FontColor -> RGBColor[0, 0, 0]
					],
					BoxBaselineShift -> 0.1
				], {20, Center}, {Left, Center}]
			},
			ContentSelectable -> False,
			ImageSize -> 600,
			PlotRange -> {{0, 600}, {0, 48}}
		]&)}
	]
}];


(* ::Input:: *)
(*RenderTMD[localPath<>"docs/test.tmd"];*)
