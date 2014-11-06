// подключение этого файла позволяет производить вывод информации
// по командам SAY и GET с ориентировкой на координаты
// верхней левой точки открытого окна            
//
#command @ <top>, <left>, <bottom>, <right> wBOX <string>               ;
                                            [COLOR <color>]             ;
      => DispBox( S_wRow()+<top>, S_wCol()+<left>,                      ;
                  S_wRow()+<bottom>, S_wCol()+<right>, <string>         ;
                  [, <color> ] )

#command @ <top>, <left> wTO <bottom>, <right> [DOUBLE]                 ;
                                              [COLOR <color>]           ;
      => DispBox( S_wRow()+<top>, S_wCol()+<left>,                      ;
                  S_wRow()+<bottom>, S_wCol()+<right>, 2                ;
                  [, <color> ] )

#command @ <top>, <left> wTO <bottom>, <right> [COLOR <color>]          ;
                                                                        ;
      => DispBox( S_wRow()+<top>, S_wCol()+<left>,                      ;
                  S_wRow()+<bottom>, S_wCol()+<right>, 1                ;
                  [, <color> ] )
                                                                        
#command @ <row>, <col> wPROMPT <prompt> [MESSAGE <msg>]                ;
                                                                        ;
      => __AtPrompt( S_wRow()+<row>, S_wCol()+<col>, <prompt> , <msg> )
      
#command @ <row>, <col> wSAY <xpr>                                      ;
                        [PICTURE <pic>]                                 ;
                        [COLOR <color>]                                 ;
                                                                        ;
      => DevPos(s_wRow()+<row>, s_wCol()+<col> )                        ;
       ; DevOutPict( <xpr>, <pic> [, <color>] )


#command @ <row>, <col> wSAY <xpr>                                      ;
                        [COLOR <color>]                                 ;
                                                                        ;
      => DevPos(s_wRow()+<row>, s_wCol()+<col> )                        ;
       ; DevOut( <xpr> [, <color>] )


#command @ <row>, <col> wGET <var>                                      ;
                        [PICTURE <pic>]                                 ;
                        [VALID <valid>]                                 ;
                        [WHEN <when>]                                   ;
                        [CAPTION <caption>]                             ;
                        [MESSAGE <message>]                             ;
                        [SEND <msg>]                                    ;
                                                                        ;
      => SetPos( s_wRow()+<row>, s_wCol()+<col> )                       ;
       ; AAdd( GetList,                                                 ;
              _GET_( <var>, <"var">, <pic>, <{valid}>, <{when}> ) )     ;
      [; ATail(GetList):Caption := <caption>]                           ;
      [; ATail(GetList):CapRow  := ATail(Getlist):row                   ;
       ; ATail(GetList):CapCol  := ATail(Getlist):col -                 ;
                              __CapLength(<caption>) - 1]               ;
      [; ATail(GetList):message := <message>]                           ;
      [; ATail(GetList):<msg>]                                          ;
       ; ATail(GetList):Display()

#command @ <row>, <col> wSAY <sayxpr>                                   ;
                        [<sayClauses,...>]                              ;
                        wGET <var>                                      ;
                        [<getClauses,...>]                              ;
                                                                        ;
      => @ <row>, <col> wSAY <sayxpr> [<sayClauses>]                    ;
       ; @ Row()-S_wRow(), Col()+1-S_wCol() wGET <var> [<getClauses>]

#command @ <row>, <col> wGET <var>                                      ;
                        [<clauses,...>]                                 ;
                        RANGE <lo>, <hi>                                ;
                        [<moreClauses,...>]                             ;
                                                                        ;
      => @ <row>, <col> wGET <var>                                      ;
                        [<clauses>]                                     ;
                        VALID { |_1| RangeCheck( _1, , <lo>, <hi> ) }   ;
                        [<moreClauses>]

#command @ <row>, <col> wGET <var>                                      ;
                        [<clauses,...>]                                 ;
                        COLOR <color>                                   ;
                        [<moreClauses,...>]                             ;
                                                                        ;
      => @ <row>, <col> wGET <var>                                      ;
                        [<clauses>]                                     ;
                        SEND colorDisp(<color>)                         ;
                        [<moreClauses>]

#command @ <row>, <col> wGET <var>                                      ;
                        CHECKBOX                                        ;
                        [VALID <valid>]                                 ;
                        [WHEN <when>]                                   ;
                        [CAPTION <caption>]                             ;
                        [MESSAGE <message>]                             ;
                        [COLOR <color>]                                 ;
                        [FOCUS <fblock>]                                ;
                        [STATE <sblock>]                                ;
                        [STYLE <style>]                                 ;
                        [SEND <msg>]                                    ;
                        [GUISEND <guimsg>]                              ;
                        [BITMAPS <aBitmaps>]                            ;
                                                                        ;
      => SetPos( s_wRow()+<row>, s_wCol()+<col> )                       ;
       ; AAdd( GetList,                                                 ;
              _GET_( <var>, <(var)>, NIL, <{valid}>, <{when}> ) )       ;
       ; ATail(GetList):Control := _CheckBox_( <var>, <caption>,        ;
                        <message>, <color>, <{fblock}>, <{sblock}>,     ;
                        <style>, <aBitmaps> )                           ;
       ; ATail(GetList):reader  := { | a, b, c, d |                     ;
                                    GuiReader( a, b, c, d ) }           ;
      [; ATail(GetList):<msg>]                                          ;
      [; ATail(GetList):Control:<guimsg>]                               ;
       ; ATail(GetList):Control:Display()


#command @ <top>, <left>, <bottom>, <right> wGET <var>                   ;
                        LISTBOX    <items>                               ;
                        [VALID <valid>]                                  ;
                        [WHEN <when>]                                    ;
                        [CAPTION <caption>]                              ;
                        [MESSAGE <message>]                              ;
                        [COLOR <color>]                                  ;
                        [FOCUS <fblock>]                                 ;
                        [STATE <sblock>]                                 ;
                        [<drop: DROPDOWN>]                               ;
                        [<scroll: SCROLLBAR>]                            ;
                        [SEND <msg>]                                     ;
                        [GUISEND <guimsg>]                               ;
                        [BITMAP <cBitmap>]                               ;
                                                                         ;
      => SetPos( s_wRow()+<top>, s_wCol()+<left> )                       ;
       ; AAdd( GetList,                                                  ;
              _GET_( <var>, <(var)>, NIL, <{valid}>, <{when}> ) )        ;
       ; ATail(GetList):Control := _ListBox_( ATail(Getlist):row,        ;
                                              ATail(Getlist):col,        ;
                        s_wRow()+<bottom>, s_wCol()+<right>,             ;
                          <var>, <items>, <caption>, <message>,          ;
                          <color>, <{fblock}>, <{sblock}>, <.drop.>,     ;
                                   <.scroll.>, <cBitmap> )               ;
       ; ATail(GetList):reader  := { | a, b, c, d |                      ;
                                    GuiReader( a, b, c, d ) }            ;
      [; ATail(GetList):<msg>]                                           ;
      [; ATail(GetList):Control:<guimsg>]                                ;
       ; ATail(GetList):Control:Display()

#command @ <row>, <col> wGET <var>                                          ;
                        PUSHBUTTON                                          ;
                        [VALID <valid>]                                     ;
                        [WHEN <when>]                                       ;
                        [CAPTION <caption>]                                 ;
                        [MESSAGE <message>]                                 ;
                        [COLOR <color>]                                     ;
                        [FOCUS <fblock>]                                    ;
                        [STATE <sblock>]                                    ;
                        [STYLE <style>]                                     ;
                        [SEND <msg>]                                        ;
                        [GUISEND <guimsg>]                                  ;
                        [SIZE X <sizex> Y <sizey>]                          ;
                        [CAPOFF X <capxoff> Y <capyoff>]                    ;
                        [BITMAP <bitmap>]                                   ;
                        [BMPOFF X <bmpxoff> Y <bmpyoff>]                    ;
                                                                            ;
      => SetPos( s_wRow()+<row>, s_wCol()+<col> )                           ;
       ; AAdd( GetList,                                                     ;
              _GET_( <var>, <(var)>, NIL, <{valid}>, <{when}> ) )           ;
       ; ATail(GetList):Control := _PushButt_( <caption>, <message>,        ;
                       <color>, <{fblock}>, <{sblock}>, <style>,            ;
                       <sizex>, <sizey>, <capxoff>, <capyoff>,              ;
                       <bitmap>, <bmpxoff>, <bmpyoff> )                     ;
       ; ATail(GetList):reader  := { | a, b, c, d |                         ;
                                    GuiReader( a, b, c, d ) }               ;
      [; ATail(GetList):<msg>]                                              ;
      [; ATail(GetList):Control:<guimsg>]                                   ;
       ; ATail(GetList):Control:Display()

#command @ <top>, <left>, <bottom>, <right> wGET <var>                    ;
                        RADIOGROUP <buttons>                              ;
                        [VALID <valid>]                                   ;
                        [WHEN <when>]                                     ;
                        [CAPTION <caption>]                               ;
                        [MESSAGE <message>]                               ;
                        [COLOR <color>]                                   ;
                        [FOCUS <fblock>]                                  ;
                        [STYLE <style>]                                   ;
                        [SEND <msg>]                                      ;
                        [GUISEND <guimsg>]                                ;
                                                                          ;
      => SetPos( s_wRow()+<top>, s_wCol()<left> )                         ;
       ; AAdd( GetList,                                                   ;
              _GET_( <var>, <(var)>, NIL, <{valid}>, <{when}> ) )         ;
       ; ATail(GetList):Control := _RadioGrp_( ATail(Getlist):row,        ;
                                               ATail(Getlist):col,        ;
                          s_wRow()+<bottom>, s_wCol()+<right>,            ;
                            <var>, <buttons>, <caption>, <message>,       ;
                     <color>, <{fblock}>, <style> )                       ;
       ; ATail(GetList):reader  := { | a, b, c, d |                       ;
                                    GuiReader( a, b, c, d ) }             ;
      [; ATail(GetList):<msg>]                                            ;
      [; ATail(GetList):Control:<guimsg>]                                 ;
       ; ATail(GetList):Control:Display()

#command @ <top>, <left>, <bottom>, <right> wGET <var>                  ;
                        TBROWSE <oBrowse>                               ;
                        [VALID <preBlock>]                              ;
                        [WHEN <postBlock>]                              ;
                        [MESSAGE <message>]                             ;
                        [SEND <msg>]                                    ;
                        [GUISEND <guimsg>]                              ;
                                                                        ;
      => SetPos( s_wRow()+<top>, S+wCol()+1+<left> )                    ;
       ; AAdd( GetList,                                                 ;
            _GET_( <var>, <(var)>, NIL, <{preBlock}>, <{postBlock}> ) ) ;
       ; <oBrowse>:ntop         := ATail(Getlist):row                   ;
       ; <oBrowse>:nleft        := ATail(Getlist):col                   ;
       ; <oBrowse>:nbottom      := s_wRow()+<bottom>                    ;
       ; <oBrowse>:nright       := s_wCol()+<right>                     ;
       ; <oBrowse>:Configure()                                          ;
       ; ATail(GetList):Control := <oBrowse>                            ;
                                                                        ;
       ; ATail(GetList):reader  := { | a, b, c, d |                     ;
                                    TBReader( a, b, c, d ) }            ;
      [; ATail(GetList):Control:Message := <message>]                   ;
      [; ATail(GetList):<msg>]                                          ;
      [; ATail(GetList):Control:<guimsg>]

#translate wSaveScreen(<top>,<left>,<bottom>,<right>)  =>               ;
            SaveScreen(S_wRow()+<top>,S_wCol()+<left>,                  ;
                       S_wRow()+<bottom>,S_wCol()+<right>)

#translate wRestScreen(<top>,<left>,<bottom>,<right>,<c>)  =>           ;
            RestScreen(S_wRow()+<top>,S_wCol()+<left>,                  ;
                       S_wRow()+<bottom>,S_wCol()+<right>,<c>)
                       
#translate wDevPos(<Row>,<Col>) =>                                      ;
            DevPos(S_wRow()+<Row>,S_wCol()+<Col>)
