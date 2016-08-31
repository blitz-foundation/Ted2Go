
Namespace ted2


Interface IKeywords
	Method Contains:Bool(word:String)
	Method Get:String(word:String)
End


#rem monkeydoc Keywords for someone language
#end
Class Keywords Implements IKeywords
	
	Method New(words:String[]=Null)
		If words = Null Then Return
		For Local kw := Eachin words
			kw = kw.Trim()
			If kw.Length = 0 Continue
			_keywords[kw.ToLower()] = kw
		Next
	End
	
	Method Contains:Bool(word:String)
		Return _keywords.Contains(word.ToLower())
	End

	Method Get:String(word:String)
		Return _keywords[word.ToLower()]
	End	
	
	
	Private
	
	Field _keywords := New StringMap<String>
	
End


Class KeywordsPlugin Extends Plugin Implements IDependsOnFileType
	
	Property Name:String() Override
		Return "KeywordsPlugin"
	End
	
	Method GetFileTypes:String[]() Virtual
		Return Null
	End
	
	Method GetMainFileType:String() Virtual
		Return "*"
	End
	
	Property Keywords:IKeywords()
		If _keywords = Null Then Init()
		Return _keywords
	End
	
	'few methods for overriding
	Method GetWordsFilePath:String() Virtual
		Return AppDir()+"keywords.json"
	End
	Method GetInternal:String() Virtual 'hardcoded words
		Return ""
	End 
	Method IsNeedLoadFromFile:Bool() Virtual
		Return True
	End 
	
	
	Private
	
	Field _keywords:IKeywords
	
	Method New()
		AddPlugin(Self)
	End
	
	Method Init()
		Local value:JsonValue
		If IsNeedLoadFromFile() Then value = JsonUtils.LoadValue(GetWordsFilePath(),GetMainFileType())
		Local s := (value<>Null ? value.ToString() Else GetInternal())
		Local words := s.Split(";")
		_keywords = New Keywords(words)
	End
	
End


#rem monkeydoc KeywordsManager class.
Storage for all keywords for all supported highlighted langs.
#end

Class KeywordsManager
	
	Function Get:IKeywords(fileType:String)
		Local plugins := Plugin.PluginsOfType<KeywordsPlugin>()
		For Local p := Eachin plugins
			If p.CheckFileTypeSuitability(fileType) Then Return p.Keywords
		Next
		Return _empty
	End

	
	Private
	
	Global _empty := New Keywords
	
End
