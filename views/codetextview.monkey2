
Namespace ted2


Class CodeTextView Extends TextView

	Field Formatter:ICodeFormatter
		
	Property Keywords:IKeywords()
		Return _keywords
	Setter(value:IKeywords)
		_keywords = value
	End
	
	Property Highlighter:Highlighter()
		Return _highlighter
	Setter(value:Highlighter)
		_highlighter = value
	End
	
		
	Method IdentAtCursor:String()
	
		Local text:=Text
		Local start:=Cursor
		
		While start And Not IsIdent( text[start] ) And text[start-1]<>10
			start-=1
		Wend
		While start And IsIdent( text[start-1] ) And text[start-1]<>10
			start-=1
		Wend
		While start<text.Length And IsDigit( text[start] ) And text[start]<>10
			start+=1
		Wend
		
		Local ends:=start
		
		While ends<text.Length And IsIdent( text[ends] ) And text[ends]<>10
			ends+=1
		Wend
		
		Return text.Slice( start,ends )
	End
	
	
	Protected
	
	Method GetIndent:Int(text:String)
		Local n := 0
		While n < text.Length And text[n] <= 32
			n += 1
		Wend
		Return n
	End
	
	Method OnKeyEvent(event:KeyEvent) Override
	
		Select event.Type
			
			Case EventType.KeyDown, EventType.KeyRepeat
				
				Local ctrl := (event.Modifiers & Modifier.Control)
				
				Select event.Key
			
					Case Key.E 'delete whole line
						If ctrl
							Local line := Document.FindLine(Cursor)
							SelectText(Document.StartOfLine(line), Document.EndOfLine(line)+1)
							ReplaceText("")
							Return
						Endif
						
					Case Key.X
						If ctrl And Not CanCopy 'nothing selected - cut whole line
							Local line := Document.FindLine(Cursor)
							SelectText(Document.StartOfLine(line), Document.EndOfLine(line)+1)
							Cut()
							Return
						Endif
						
					Case Key.C, Key.Insert
						If ctrl And Not CanCopy 'nothing selected - copy whole line
							Local cur := Cursor
							Local line := Document.FindLine(Cursor)
							SelectText(Document.StartOfLine(line), Document.EndOfLine(line))
							Copy()
							SelectText(cur,cur)'restore
							Return
						Endif
						
					Case Key.Enter 'auto indent
						
						DoFormat()
										
						Local line := CursorRow
						Local text := Document.GetLine( line )
						Local indent := GetIndent(text)
						
						Local s := (indent ? text.Slice(0, indent) Else "")
						ReplaceText( "~n"+s )
						
						Return
						
					Case Key.Home 'smart Home behaviour
			
						Local line := CurrentTextLine
						Local txt := line.text
						Local n := 0
						Local n2 := txt.Length
						'check for whitespaces before cursor
						While (n < n2 And IsSpace(txt[n]))
							n += 1
						Wend
						n += line.posStart
						Local newPos := 0
						If n >= Cursor And Cursor > line.posStart
							newPos = line.posStart
						Else
							newPos = n
						Endif
							
						If event.Modifiers & Modifier.Shift 'selection
							SelectText(Anchor, newPos)
						Else
							SelectText(newPos, newPos)
						Endif
					
						Return 
						
					Case Key.Up, Key.Down, Key.Tab
						DoFormat()
						
				End
				
				
			Case EventType.KeyChar
		
				If Not IsIdent( event.Text[0] )
					DoFormat()
				Endif
				
		End
		
		Super.OnKeyEvent(event)
		
	End
	
	
	Private 
	
	Field _keywords:IKeywords
	Field _highlighter:Highlighter
	
	Method DoFormat()
		'If Formatter Then Formatter.Format
	End
	
End
