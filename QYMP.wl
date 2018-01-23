(* ::Package:: *)

(* ::Text:: *)
(*Qingyun Music Player*)


localPath=NotebookDirectory[];
<<(localPath<>"Assets\\assets.wl")    (* graphics *)
<<(localPath<>"Lib\\library.wl")      (* library *)
<<(localPath<>"Lib\\uiControls.wl")   (* controls *)
<<(localPath<>"Lib\\uiUser.wl")       (* UI for common users *)
<<(localPath<>"Lib\\uiDeveloper.wl")  (* UI for developers *)
<<(localPath<>"Lib\\qymToken.wl")     (* QYM tokenizer *)
<<(localPath<>"Lib\\qysToken.wl")     (* QYS tokenizer *)
<<(localPath<>"Lib\\parser.wl")       (* parser *)


(* temporary function *)
QYMParse[filename_]:=integrate[#MusicClips,#Effects]&@parse[QYM`tokenizer[filename]];
QYSParse[filename_]:=integrate[#MusicClips,#Effects]&@parse[QYS`Tokenize[filename]];


(* user data *)
version=201;
userPath=$HomeDirectory<>"\\AppData\\Local\\QYMP\\";
cloudPath="http://qymp.ob-studio.cn/assets/";
If[!DirectoryQ[userPath],CreateDirectory[userPath]];
If[!DirectoryQ[userPath<>"buffer\\"],CreateDirectory[userPath<>"buffer\\"]];
If[!DirectoryQ[userPath<>"images\\"],CreateDirectory[userPath<>"images\\"]];
template=<|"Version"->version,"Language"->"chs","Developer"->False,"Player"->"Old"|>;
If[!FileExistsQ[userPath<>"Default.json"],Export[userPath<>"Default.json",template]];
userInfo=Association@Import[userPath<>"Default.json"];
If[userInfo[["Version"]]<version,
	Do[
		If[!KeyExistsQ[userInfo,tag],AppendTo[userInfo,tag->template[[tag]]]],
	{tag,Keys@template}];
	userInfo[["Version"]]=version;
	Export[userPath<>"Default.json",userInfo];
];
If[!FileExistsQ[userPath<>"Buffer.json"],Export[userPath<>"Buffer.json",{}]];
bufferHash=Association@Import[userPath<>"Buffer.json"];
If[!FileExistsQ[userPath<>"Favorite.json"],Export[userPath<>"Favorite.json",{}]];
favorite=Import[userPath<>"Favorite.json"];
If[!FileExistsQ[userPath<>"Image.json"],Export[userPath<>"Image.json",{}]];
imageData=Association/@Association@Import[userPath<>"image.json"];


(* local data *)
instrData=Association@Import[localPath<>"instr.json"];                               (* instruments *)
colorData=Association@Import[localPath<>"color.json"];                               (* colors *)
styleColor=RGBColor/@Association@colorData[["StyleColor"]];
buttonColor=RGBColor/@#&/@Association/@Association@colorData[["ButtonColor"]];
pageSelectorColor=RGBColor/@#&/@Association/@Association@colorData[["PageSelectorColor"]];
styleData=Association/@Association@Import[localPath<>"style.json"];                  (* styles *)
styleDict=Normal@Module[{outcome={}},
	If[KeyExistsQ[#,"FontSize"],AppendTo[outcome,FontSize->#[["FontSize"]]]];
	If[KeyExistsQ[#,"FontFamily"],AppendTo[outcome,FontFamily->#[["FontFamily"]]]];
	If[KeyExistsQ[#,"FontWeight"],AppendTo[outcome,FontWeight->ToExpression@#[["FontWeight"]]]];
	If[KeyExistsQ[#,"FontColor"],AppendTo[outcome,FontColor->styleColor[[#[["FontColor"]]]]]];
outcome]&/@styleData;
dictionary=Association/@AssociationMap[Import[localPath<>"Lang\\"<>#<>".json"]&,langList];       (* languages *)
refreshLanguage;


(* ::Input::Initialization:: *)
refresh;updateImage;updateBuffer;


(* ::Input::Initialization:: *)
QYMP;


(* ::Input:: *)
(*AudioStop[];*)


(* ::Input:: *)
(*AudioStop[];AudioPlay@QYSParse[localPath<>"Songs\\Touhou\\Houkainohi.qys"];*)


(* ::Input:: *)
(*AudioStop[];AudioPlay@QYSParse[localPath<>"Songs\\test.qys"];*)


(* ::Input:: *)
(*Options[QYSParse[localPath<>"Songs\\Touhou\\Houkainohi.qys"]]*)


(* ::Input:: *)
(*Print[index["Touhou\\Hartmann_No_Youkai_Otome","Comment"]];*)


(* ::Input:: *)
(*EmitSound@Sound@SoundNote[23,.5,"Halo"]*)


(* ::Input:: *)
(*EmitSound@Sound@SoundNote["PanFlute"]*)
