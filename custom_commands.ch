
#xcommand TRY      			=> BEGIN SEQUENCE WITH {|o| break(o)}
#xcommand CATCH [<!oErr!>] 	=> RECOVER [USING <oErr>] <-oErr->
#xcommand FINALLY 			=> ALWAYS
#xcommand ENDTRY 			=> ENDSEQUENCE

// in line IF & UNLESS commands
#xcommand <Command1> [<Commandn>] IF <lCondition> => IF <lCondition> ; <Command1> [<Commandn>]; ENDIF ;

#xcommand <Command1> [<Commandn>] UNLESS <lCondition> => IF !(<lCondition>) ; <Command1> [<Commandn>]; ENDIF ;