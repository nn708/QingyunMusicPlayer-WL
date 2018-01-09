(* ::Package:: *)

uiSettings:=DynamicModule[{choices},
	choices=userInfo;
	CreateDialog[Column[{Spacer[{40,40}],
		caption["_Settings","Title"],Spacer[1],
		Grid[{
			{caption["_ChooseIdentity","Text"],
				RadioButtonBar[Dynamic@choices[["Developer"]],{
					False->caption["_NormalUser","Text"],
					True->caption["_Developer","Text"]
				}]
			},
			{caption["_ChooseLanguage","Text"],
				RadioButtonBar[Dynamic@choices[["Language"]],langDict]}
			}
		],Spacer[1],
		Row[{
			Button[text[["Save"]],
				langData=Association@Import[path<>"Lang\\"<>choices[["Language"]]<>".json"];
				tagName=Association@langData[["TagName"]];
				instrName=Association@langData[["Instrument"]];
				errorDict=Association@langData[["Error"]];
				text=Association@langData[["Caption"]];
				userInfo=choices;
				Export[userPath<>"Default.json",Normal@userInfo];
				DialogReturn[QYMP],
			ImageSize->150],
			Spacer[10],
			Button[text[["Return"]],DialogReturn[QYMP],ImageSize->150]
		}],Spacer[{40,40}]
	},Center,ItemSize->40],
	WindowTitle->text[["Settings"]]]
];


(* ::Input:: *)
(*uiPlayer["Touhou\\Dream_Battle"]*)


uiPlayer[song_]:=Module[{image,audio,imageExist},
	AudioStop[];
	If[KeyExistsQ[index[[song]],"Image"],
		imageExist=True;image=Import[userPath<>"Images\\"<>index[[song,"Image"]]],
		imageExist=False
	];
	audio=Import[userPath<>"Buffer\\"<>song<>".buffer","MP3"];
	duration=Duration[audio];
	current=AudioPlay[audio];
	CreateDialog[Row[{
		If[imageExist,Row[{Spacer[48],Column[{Spacer[{40,40}],
			Tooltip[Image[image,ImageSize->If[ImageAspectRatio[image]>1,{360,UpTo[720]},{UpTo[800],400}]],
				If[KeyExistsQ[imageData,index[[song,"Image"]]],
					Column[If[KeyExistsQ[imageData[[index[[song,"Image"]]]],#],
						tagName[[#]]<>": "<>imageData[[index[[song,"Image"]],#]],
						Nothing
					]&/@imageTags],
					text[["NoImageInfo"]]
				]
			],
		Spacer[{40,40}]}]}],Nothing],Spacer[48],
		Column[{Spacer[{60,60}],
			Row[{caption[index[[song,"SongName"]],"Title"],
				If[KeyExistsQ[index[[song]],"Comment"],
					caption[" ("<>index[[song,"Comment"]]<>")","TitleComment"],
					Nothing
				]
			}],
			Spacer[1],
			Column[If[KeyExistsQ[index[[song]],#],
				caption[tagName[[#]]<>": "<>index[[song,#]],"Text"],
				Nothing
			]&/@{"Composer","Lyricist","Adapter"},Alignment->Center],
			Spacer[1],
			If[KeyExistsQ[index[[song]],"Abstract"],
				Column[caption[#,"Text"]&/@StringSplit[index[[song,"Abstract"]],"\n"],Center],
				Nothing
			],
			Spacer[1],
			Row[{
				Dynamic[timeDisplay[current["Position"]]],
				Spacer[8],
				ProgressIndicator[Dynamic[current["Position"]/duration],ImageSize->{240,16}],
				Spacer[8],
				timeDisplay[duration]
			}],
			Spacer[1],
			Row[{
				DynamicModule[{style="Default"},
					Dynamic@Switch[current["State"],
						"Playing",EventHandler[button["Pause",style],{
							"MouseDown":>(style="Clicked"),
							"MouseUp":>(style="Default";current["State"]="Paused")
						}],
						"Paused"|"Stopped",EventHandler[button["Play",style],{
							"MouseDown":>(style="Clicked"),
							"MouseUp":>(style="Default";current["State"]="Playing")
						}]
					]
				],
				Spacer[20],
				DynamicModule[{style="Default"},
					EventHandler[Dynamic@button["Stop",style],{
						"MouseDown":>(style="Clicked"),
						"MouseUp":>(style="Default";current["State"]="Stopped")
					}]
				],
				Spacer[20],
				DynamicModule[{style="Default"},
					EventHandler[Dynamic@button["ArrowL",style],{
						"MouseDown":>(style="Clicked";),
						"MouseUp":>(style="Default";AudioStop[];DialogReturn[QYMP];)
					}]
				]		
			},ImageSize->{300,60},Alignment->Center],Spacer[{60,60}]
		},Alignment->Center,ItemSize->36],
	Spacer[48]},Alignment->Center,ImageSize->Full],
	Background->styleColor[["Background"]],WindowTitle->text[["Playing"]]<>": "<>index[[song,"SongName"]]];
];


uiModifySong[song_]:=DynamicModule[{textInfo},
	textInfo=getTextInfo[song];
	CreateDialog[Column[{Spacer[{20,20}],
		caption[textInfo[["SongName"]],"Title"],
		Spacer[1],
		Column[Row[{Spacer[40],
			caption[tagName[[#]],"Text"],
			Spacer[16],
			InputField[Dynamic@textInfo[[#]],String],
		Spacer[40]}]&/@textInfoTags],
		Spacer[1],
		Grid[{
			{Button[text[["Save"]],putTextInfo[song,textInfo],ImageSize->150,Enabled->Dynamic[textInfo[["SongName"]]!=""]],
			Button[text[["Undo"]],textInfo=getTextInfo[song],ImageSize->150]},
			{Button[text[["DeleteSong"]],DialogReturn[uiDeleteSong[song]],ImageSize->150],
			Button[text[["Return"]],DialogReturn[QYMP],ImageSize->150]}
		}],Spacer[{20,20}]
	},Center,ItemSize->Full,Spacings->1],
	WindowTitle->text[["ModifySong"]]];
];


ignoreList={"temp.qys","test.qys"};
uiAddSong:=DynamicModule[{songPath,textInfo,candidates},
	textInfo=AssociationMap[""&,textInfoTags];
	candidates=Complement[StringDrop[FileNames["*.qys"|"*.qym","Songs",Infinity],6],
		#<>"."<>index[[#,"Format"]]&/@songList,
		ignoreList
	];
	CreateDialog[Column[{Spacer[{40,40}],
		caption["_AddSong","Title"],
		Spacer[4],
		Row[{text[["SongPath"]],Spacer[12],PopupMenu[Dynamic@songPath,candidates,ImageSize->200]}],
		Column[Row[{Spacer[40],
			caption[tagName[[#]],"Text"],
			Spacer[16],
			InputField[Dynamic@textInfo[[#]],String],
		Spacer[40]}]&/@textInfoTags],
		Spacer[4],
		Row[{Button[text[["Add"]],
			song=StringDrop[songPath,-4];
			AppendTo[bufferHash,song->toBase32@FileHash[path<>"Songs\\"<>songPath]];
			Export[userPath<>"Buffer.json",Normal@bufferHash];
			audio=If[StringTake[songPath,-3]=="qys",QYSParse,QYMParse][path<>"Songs\\"<>songPath];
			Export[userPath<>"Buffer\\"<>song<>".buffer",audio,"MP3"];
			metaInfo=Values[Options[audio,MetaInformation]][[1]];
			metaInfo[["TrackCount"]]=ToString[metaInfo[["TrackCount"]]];
			metaInfo[["Duration"]]=ToString[metaInfo[["Duration"]],InputForm];
			metaInfo[["Instruments"]]=ToString[metaInfo[["Instruments"]],InputForm];
			AppendTo[index,song->metaInfo];
			putTextInfo[song,textInfo];
			DialogReturn[QYMP],
		ImageSize->150,Enabled->Dynamic[textInfo[["SongName"]]!=""]],
		Spacer[20],
		Button[text[["Return"]],DialogReturn[QYMP],ImageSize->150]}],
	Spacer[{40,40}]},Center,ItemSize->Full,Spacings->1],
	WindowTitle->text[["AddSong"]]]
];


(* ::Input:: *)
(*uiAddSong;*)


uiDeleteSong[song_]:=CreateDialog[Column[{"",
	text[["SureToRemove"]],"",
	Row[{
		Button[text[["Confirm"]],
			index=Delete[index,song];
			DeleteFile[path<>"Meta\\"<>song<>".meta"];
			DialogReturn[QYMP],
		ImageSize->100],
		Spacer[20],
		Button[text[["Return"]],DialogReturn[QYMP],ImageSize->100]			
	}],""
},Center,ItemSize->36],
WindowTitle->text[["DeleteSong"]]];


uiAbout:=CreateDialog[Column[{Spacer[{40,40}],
	caption["_About","Title"],
	Spacer[{20,20}],
	Row[{Spacer[60],Column[Join[
		{caption["_QYMP","Subtitle"],Spacer[4]},
		caption[tagName[[#]]<>": "<>aboutInfo[[#]],"Text"]&/@aboutTags
	],Alignment->Left,ItemSize->20],Spacer[60]}],
	Spacer[{20,20}],
	Button[text[["Return"]],DialogReturn[QYMP],ImageSize->100],
Spacer[{40,40}]},Center,ItemSize->Full],
WindowTitle->text[["About"]],Background->styleColor[["Background"]]];


(* ::Input:: *)
(*uiAbout;*)


QYMP:=DynamicModule[{song},
	refresh;
	AudioStop[];
	CreateDialog[Column[{Spacer[{40,40}],
		Row[{
			Row[{Spacer[40],caption["_QYMP","BigTitle"]},Alignment->Left,ImageSize->320],
			Row[Join[{
				DynamicModule[{style="Default"},
					EventHandler[Dynamic@button["Play",style],{
						"MouseDown":>(style="Clicked"),
						"MouseUp":>(style="Default";DialogReturn[uiPlayer[song]];)
					}]
				],
				Spacer[10]},
				If[userInfo[["Developer"]],
					{DynamicModule[{style="Default"},
						EventHandler[Dynamic@button["Modify",style],{
							"MouseDown":>(style="Clicked"),
							"MouseUp":>(style="Default";DialogReturn[uiModifySong[song]];)
						}]
					],
					Spacer[10],
					DynamicModule[{style="Default"},
						EventHandler[Dynamic@button["Add",style],{
							"MouseDown":>(style="Clicked"),
							"MouseUp":>(style="Default";DialogReturn[uiAddSong];)
						}]
					],
					Spacer[10]},					
				{Nothing}],
				{DynamicModule[{style="Default"},
					EventHandler[Dynamic@button["About",style],{
						"MouseDown":>(style="Clicked"),
						"MouseUp":>(style="Default";DialogReturn[uiAbout];)
					}]
				],
				Spacer[10],
				DynamicModule[{style="Default"},
					EventHandler[Dynamic@button["Settings",style],{
						"MouseDown":>(style="Clicked"),
						"MouseUp":>(style="Default";DialogReturn[uiSettings];)
					}]
				],
				Spacer[10],
				DynamicModule[{style="Default"},
					EventHandler[Dynamic@button["Exit",style],{
						"MouseDown":>(style="Clicked"),
						"MouseUp":>(style="Default";DialogReturn[];)
					}]
				],
				Spacer[40]}
			],Alignment->Right,ImageSize->{480,56}]
		}],
		Spacer[1],
		Dynamic@Row[{Spacer[60],SetterBar[Dynamic@song,
			#->Row[{
				Style[index[[#,"SongName"]],24,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"],
				Spacer[20],
				If[KeyExistsQ[index[[#]],"Comment"],Style[index[[#,"Comment"]],20,Gray,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"],Nothing]
			},ImageSize->{800,30}]&/@songListPaged[[page]],
			Appearance->"Vertical"
		],Spacer[60]}],Spacer[1],
		Row[Join[{
			Dynamic@If[page<=1,pageSelector["Prev","Disabled"],
			DynamicModule[{style="Default"},
				EventHandler[Dynamic@pageSelector["Prev",style],{
					"MouseDown":>(style="Clicked"),
					"MouseUp":>(style="Default";page--;)
				}]
			]],
			Spacer[20]},
			Flatten@Array[{
				Dynamic@If[page==#,pageSelector[#,"Current",32],
				DynamicModule[{style="Default"},
					EventHandler[Dynamic@pageSelector[#,style,32],{
						"MouseDown":>(style="Clicked"),
						"MouseUp":>(style="Default";page=#;)
					}]
				]
			],Spacer[6]}&,pageCount],
			{Spacer[14],
			Dynamic@If[page>=pageCount,pageSelector["Next","Disabled"],
			DynamicModule[{style="Default"},
				EventHandler[Dynamic@pageSelector["Next",style],{
					"MouseDown":>(style="Clicked"),
					"MouseUp":>(style="Default";page++;)
				}]
			]]}
		],ImageSize->{500,60},Alignment->Center],Spacer[{40,40}]
	},Center,ItemSize->Full],
	WindowTitle->text[["QYMP"]],Background->styleColor[["Background"]]]
];


(* ::Input:: *)
(*QYMP;*)
