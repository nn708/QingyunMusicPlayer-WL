(* ::Package:: *)

BeginPackage["Thulium`Interface`Playlist`", {
  "Thulium`System`",
  "Thulium`Assets`",
  "Thulium`StyleSheet`"
}];

newPlaylist::usage = "newPlaylist";

Begin["`Private`"];

newPlaylist[playlist_] := Block[
  {
    info, length, songList, indexList, indexWidth, pageCount, display, notebook
  },
  
  info = PlaylistIndex[playlist];
  length = Length @ info["SongList"];
  pageCount = Ceiling[length / 10];
  songList = Partition["Song" /. info["SongList"], UpTo @ Ceiling[length / pageCount]];
  indexList = Partition["Index" /. info["SongList"], UpTo @ Ceiling[length / pageCount]];
  indexWidth = 8 * Max[0, TextLength /@ DeleteCases[indexList, "Index", Infinity]];
  If[Thulium`PageIndex[playlist] > pageCount, Thulium`PageIndex[playlist] = pageCount];
  
  Module[{page = Thulium`PageIndex[playlist], index = 1},
    With[
      {
        ChsFont = ChsFont, TextDict = TextDict,
        tmPageSelBox = If[pageCount > 7, tmPageSelBox2, tmPageSelBox1]
      },
      
      display = Table[Table[
        With[{songInfo = SongIndex[info["Path"] <> songList[[pg, id]]]},
          {TemplateBox[{Unevaluated[index], id,
            GridBox[
              {
                {TagName["FileName"] <> ":", songList[[pg, id]]},
                {TagName["SongName"] <> ":", songInfo["SongName"]},
                If[songInfo["Uploader"] =!= "",
                  {TagName["Uploader"] <> ":", songInfo["Uploader"]},
                Nothing]
              },
              ColumnSpacings -> 1,
              ColumnAlignments -> {Center, Left}
            ],
            RowBox[{
              If[indexWidth > 0,
                PaneBox[
                  AdjustmentBox[
                    StyleBox[indexList[[pg, id]],
                      FontSize -> 12,
                      FontFamily -> ChsFont,
                      FontColor -> GrayLevel[0.3]
                    ],
                    BoxMargins -> {{0, 0.6}, {0, 0}},
                    BoxBaselineShift -> -0.4
                  ],
                  ImageSize -> indexWidth,
                  Alignment -> Center
                ],
                Nothing
              ],
              StyleBox[songInfo["SongName"],
                FontSize -> 14,
                FontFamily -> ChsFont
              ],
              TemplateBox[{12}, "Spacer1"],
              StyleBox[songInfo["Comment"],
                FontSize -> 12,
                FontFamily -> ChsFont,
                FontColor -> GrayLevel[0.3]
              ]
            }]
          }, "<Setter-Local>"]}
        ],
      {id, Length @ songList[[pg]]}], {pg, pageCount}];
  
      notebook = CreateDialog[
        {
          Cell[BoxData @ RowBox[{
            StyleBox[info["Title"], "Title"],
            TemplateBox[{280}, "Spacer1"],
            AdjustmentBox[
              TemplateBox[{"Return", Null}, "<Button-Local>"],
              BoxBaselineShift -> -0.2
            ]
          }], "Title", CellTags -> "Title"],
          
          If[info["Comment"] =!= "", Cell[BoxData @ PaneBox[
            StyleBox[info["Comment"], "Subtitle"]
          ], "Subtitle"], Nothing],
          
          Cell[BoxData @ PaneBox[PaneSelectorBox[
            Array[Function[{pg},
              pg -> GridBox[Array[
                Function[{id}, display[[pg, id]]],
              Length @ songList[[pg]]]]
            ], pageCount],
          Dynamic[page]]], "SetterList", CellTags -> "SetterList"],
          
          Cell[BoxData @ tmPageSelBox[page, pageCount], "PageSelector", CellTags -> "PageSelector"]
        },
        
        StyleDefinitions -> Notebook[{
          tmSetter,
          tmButton,
          tmPageSel,
          
          Cell[StyleData["Title"],
            CellMargins -> {{0, 0}, {0, 24}},
            TextAlignment -> Center,
            FontFamily -> ChsFont,
            FontSize -> 24,
            FontWeight -> Bold
          ],
          
          Cell[StyleData["Subtitle"],
            CellMargins -> {{0, 0}, {0, 0}},
            TextAlignment -> Center,
            FontFamily -> ChsFont,
            FontSize -> 14,
            PaneBoxOptions -> {Alignment -> Left, ImageSize -> 440}
          ],
          
          Cell[StyleData["SetterList"],
            CellMargins -> {{0, 0}, {16, 16}},
            TextAlignment -> Center,
            PaneBoxOptions -> {
              Alignment -> {Center, Center},
              ImageSize -> {Automatic, 280}
            },
            GridBoxOptions -> {RowSpacings -> 0}
          ],
          
          Cell[StyleData["PageSelector"],
            CellMargins -> {{0, 0}, {24, 0}},
            TextAlignment -> Center
          ],
          
          Cell[StyleData["<Button-Local>"],
            TemplateBoxOptions -> {DisplayFunction -> Function[
              TemplateBox[{
                TemplateBox[{#1, Opacity[0], RGBColor[0, 0.7, 0.94], RGBColor[0, 0.7, 0.94], 32}, "<Button-Round>"],
                TemplateBox[{#1, RGBColor[0, 0.7, 0.94], RGBColor[0, 0.7, 0.94], RGBColor[1, 1, 1], 32}, "<Button-Round>"],
                TemplateBox[{#1, RGBColor[0, 0.7, 0.94, 0.3], RGBColor[0, 0.7, 0.94], RGBColor[0, 0.7, 0.94], 32}, "<Button-Round>"],
                #2, StyleBox[TextDict[#1], FontFamily -> ChsFont]
              }, "<Button>"]
            ]}
          ],
          
          Cell[StyleData["<Setter-Button>"],
            TemplateBoxOptions -> {DisplayFunction -> Function[
              TemplateBox[{
                PaneSelectorBox[{
                  True -> TemplateBox[{#1, Opacity[0], RGBColor[0, 0.7, 0.94], RGBColor[0, 0.7, 0.94], 18}, "<Button-Round>"],
                  False -> TemplateBox[{#1, Opacity[0], Opacity[0], Opacity[0], 18}, "<Button-Round>"]
                }, #3],
                TemplateBox[{#1, RGBColor[0, 0.7, 0.94], RGBColor[0, 0.7, 0.94], RGBColor[1, 1, 1], 18}, "<Button-Round>"],
                TemplateBox[{#1, RGBColor[0, 0.7, 0.94, 0.3], RGBColor[0, 0.7, 0.94], RGBColor[0, 0.7, 0.94], 18}, "<Button-Round>"],
                #2
              }, "<Button-no-Tooltip>"]
            ]}
          ],
          
          Cell[StyleData["<Setter-Item-Local>"],
            TemplateBoxOptions -> {DisplayFunction -> Function[
              TemplateBox[{
                RowBox[
                  {
                    PaneBox[
                      StyleBox[#1, FontSize -> 14, FontFamily -> ChsFont],
                      ImageSize -> 450,
                      Alignment -> Left
                    ],
                    AdjustmentBox[
                      TemplateBox[{"Play", Null, #4}, "<Setter-Button>"],
                      BoxBaselineShift -> -0.1
                    ]
                  }
                ],
                RGBColor[0, 0, 0], #2, #3, 480, 18
              }, "<Setter-Item>"]
            ]}
          ],
          
          Cell[StyleData["<Setter-Local>"],
            TemplateBoxOptions -> {DisplayFunction -> Function[
              TemplateBox[{
                #1, #2, #3,
                TemplateBox[{#4, RGBColor[0.96, 0.98, 1], RGBColor[0.96, 0.98, 1], False}, "<Setter-Item-Local>"],
                TemplateBox[{#4, RGBColor[0.96, 1, 0.98], RGBColor[0.94, 1, 0.98], True}, "<Setter-Item-Local>"],
                TemplateBox[{#4, RGBColor[0.92, 1, 0.98], RGBColor[0.88, 1, 0.98], False}, "<Setter-Item-Local>"],
                TemplateBox[{#4, RGBColor[0.97, 1, 0.97], RGBColor[0.97, 1, 0.97], False}, "<Setter-Item-Local>"]
              }, "<Setter>"]
            ]}
          ]
        }],
        
        ShowCellLabel -> False,
        ShowCellTags -> False,
        ShowCellBracket -> False,
        CellGrouping -> Manual,
        Background -> RGBColor[1, 1, 1],
        WindowTitle -> TagName[info["Type"]] <> " - " <> info["Title"],
        WindowElements -> {},
        WindowFrameElements -> {"CloseBox", "MinimizeBox"},
        WindowSize -> {1200, 900},
        WindowFrame -> "ModelessDialog",
        Magnification -> 2,
        Saveable -> False,
        Editable -> False,
        Deployed -> True,
        Evaluatable -> False
      ];
    ];
    
    Evaluate[Unique[]] := index;
    Evaluate[Unique[]] := page;
  ];
];

End[];

EndPackage[];


(* ::Input:: *)
(*Thulium`Update`CheckUpdate;*)


(* ::Input:: *)
(*newPlaylist["All"];*)


(* ::Input:: *)
(*newPlaylist["TH11-Chireiden.qyl"];*)


(* ::Input:: *)
(*newPlaylist["Clannad.qyl"];*)


(* ::Input:: *)
(*SongIndex["Touhou/TH11-Chireiden/3rd_Eye"]*)


(* ::Input:: *)
(*PlaylistIndex["Clannad.qyl"]*)