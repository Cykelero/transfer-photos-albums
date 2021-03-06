JsOsaDAS1.001.00bplist00�Vscripto� f u n c t i o n   p a c k R o o t F o l d e r s B y N a m e ( f o l d e r N a m e s ,   p r o g r e s s C a l l b a c k )   { 
 	 r e t u r n   f o l d e r N a m e s . m a p ( f o l d e r N a m e   = >   { 
 	 	 c o n s t   f o l d e r   =   p h o t o s A p p . f o l d e r s . b y N a m e ( f o l d e r N a m e ) ; 
 	 	 r e t u r n   p a c k F o l d e r ( f o l d e r ,   p r o g r e s s C a l l b a c k ) ; 
 	 } ) ; 
 } 
 
 f u n c t i o n   u n p a c k R o o t F o l d e r s ( p a c k e d F o l d e r s ,   p r o g r e s s C a l l b a c k )   { 
 	 r e t u r n   p a c k e d F o l d e r s . r e d u c e ( ( a c c u m u l a t e d M i s s i n g I t e m s ,   p a c k e d F o l d e r )   = >   { 
 	 	 r e t u r n   a c c u m u l a t e d M i s s i n g I t e m s . c o n c a t ( u n p a c k F o l d e r ( p a c k e d F o l d e r ) ) ; 
 	 } ,   [ ] ) ; 
 } 
 
 
 f u n c t i o n   p a c k F o l d e r ( f o l d e r ,   p r o g r e s s C a l l b a c k )   { 
 	 t r y   { 
 	 	 r e t u r n   { 
 	 	 	 t y p e :   ' f o l d e r ' , 
 	 	 	 n a m e :   f o l d e r . n a m e ( ) , 
 	 	 	 c h i l d r e n :   t o P r o p e r A r r a y ( f o l d e r . c o n t a i n e r s ) 
 	 	 	 	 . m a p ( c h i l d   = >   { 
 	 	 	 	 	 r e t u r n   i s A l b u m ( c h i l d )   ?   p a c k A l b u m ( c h i l d ,   p r o g r e s s C a l l b a c k )   : 	   p a c k F o l d e r ( c h i l d ,   p r o g r e s s C a l l b a c k ) ; 
 	 	 	 	 } ) 
 	 	 } ; 
 	 }   c a t c h   ( e r r o r )   { 
 	 	 t h r o w   E r r o r ( ` C a n ' t   f i n d   s p e c i f i e d   f o l d e r . ` ) ; 
 	 } 
 } 
 
 f u n c t i o n   u n p a c k F o l d e r ( p a c k e d F o l d e r ,   d e s t i n a t i o n F o l d e r ,   p r o g r e s s C a l l b a c k )   { 
 	 l e t   u n p a c k e d F o l d e r ; 
 	 l e t   m i s s i n g I t e m s   =   [ ] ; 
 
 	 c o n s t   a t R o o t   =   ! d e s t i n a t i o n F o l d e r ; 
 	 c o n s t   i n i t i a l F o l d e r N a m e   =   a t R o o t   ?   ` $ { p a c k e d F o l d e r . n a m e }   ( 0 % ) `   :   p a c k e d F o l d e r . n a m e ; 
 	 
 	 / /   C o u n t   f o l d e r s ,   p r e p a r e   p r o g r e s s   r e p o r t i n g 
 	 i f   ( a t R o o t )   { 
 	 	 f u n c t i o n   c o u n t S u b t h i n g s ( p a c k e d T h i n g )   { 
 	 	 	 i f   ( p a c k e d T h i n g . t y p e   ! = =   ' f o l d e r ' )   r e t u r n   1 ; 
 	 	 	 r e t u r n   p a c k e d T h i n g . c h i l d r e n . r e d u c e ( ( a c c u m u l a t e d C o u n t ,   c h i l d )   = >   { 
 	 	 	 	 r e t u r n   a c c u m u l a t e d C o u n t   +   c o u n t S u b t h i n g s ( c h i l d ) ; 
 	 	 	 } ,   1 ) ; 
 	 	 } 
 	 	 
 	 	 c o n s t   t o t a l T h i n g s   =   c o u n t S u b t h i n g s ( p a c k e d F o l d e r ) ; 
 	 	 
 	 	 l e t   r e s t o r e d T h i n g C o u n t   =   0 ; 
 	 	 p r o g r e s s C a l l b a c k   =   f u n c t i o n ( )   { 
 	 	 	 r e s t o r e d T h i n g C o u n t + + ; 
 	 	 	 p r o g r e s s P e r c e n t a g e   =   M a t h . r o u n d ( r e s t o r e d T h i n g C o u n t   /   t o t a l T h i n g s   *   1 0 0 ) ; 
 	 	 	 u n p a c k e d F o l d e r . n a m e   =   ` $ { p a c k e d F o l d e r . n a m e }   ( $ { p r o g r e s s P e r c e n t a g e } % ) ` ; 
 	 	 } ; 
 	 } 
 
 	 / /   C r e a t e   f o l d e r 
 	 i f   ( a t R o o t )   { 
 	 	 p h o t o s A p p . m a k e ( { n e w :   ' f o l d e r ' ,   n a m e d :   i n i t i a l F o l d e r N a m e } ) ; 
 	 }   e l s e   { 
 	 	 p h o t o s A p p . m a k e ( { n e w :   ' f o l d e r ' ,   n a m e d :   i n i t i a l F o l d e r N a m e ,   a t :   d e s t i n a t i o n F o l d e r } ) ; 
 	 } 
 	 c o n s t   e p h e m e r a l U n p a c k e d F o l d e r   =   ( d e s t i n a t i o n F o l d e r   | |   p h o t o s A p p ) . f o l d e r s . b y N a m e ( i n i t i a l F o l d e r N a m e ) ; 
 	 u n p a c k e d F o l d e r   =   p h o t o s A p p . f o l d e r s . b y I d ( e p h e m e r a l U n p a c k e d F o l d e r . i d ( ) ) ; 
 	 
 	 / /   A d d   c h i l d r e n 
 	 p a c k e d F o l d e r . c h i l d r e n . s l i c e ( 0 ) . r e v e r s e ( ) 
 	 	 . f o r E a c h ( c h i l d   = >   { 
 	 	 	 s w i t c h   ( c h i l d . t y p e )   { 
 	 	 	 	 c a s e   ' f o l d e r ' : 
 	 	 	 	 	 m i s s i n g I t e m s   =   m i s s i n g I t e m s . c o n c a t ( u n p a c k F o l d e r ( c h i l d ,   u n p a c k e d F o l d e r ,   p r o g r e s s C a l l b a c k ) ) ; 
 	 	 	 	 	 b r e a k ; 
 	 	 	 	 c a s e   ' a l b u m ' : 
 	 	 	 	 	 m i s s i n g I t e m s   =   m i s s i n g I t e m s . c o n c a t ( u n p a c k A l b u m ( c h i l d ,   u n p a c k e d F o l d e r ) ) ; 
 	 	 	 	 	 p r o g r e s s C a l l b a c k ( ) ; 
 	 	 	 	 	 b r e a k ; 
 	 	 	 } 
 	 	 } ) ; 
 	 
 	 p r o g r e s s C a l l b a c k ( ) ; 
 	 
 	 / /   F i n a l i z e   f o l d e r   n a m e 
 	 i f   ( a t R o o t )   { 
 	 	 u n p a c k e d F o l d e r . n a m e   =   p a c k e d F o l d e r . n a m e ; 
 	 } 
 	 
 	 r e t u r n   m i s s i n g I t e m s ; 
 } 
 
 f u n c t i o n   p a c k A l b u m ( a l b u m ,   p r o g r e s s C a l l b a c k )   { 
 	 p r o g r e s s C a l l b a c k ( a l b u m . m e d i a I t e m s . l e n g t h ) ; 
 	 r e t u r n   { 
 	 	 t y p e :   ' a l b u m ' , 
 	 	 n a m e :   a l b u m . n a m e ( ) , 
 	 	 c h i l d r e n :   t o P r o p e r A r r a y ( a l b u m . m e d i a I t e m s . i d ( ) ) 
 	 } ; 
 } 
 
 f u n c t i o n   u n p a c k A l b u m ( p a c k e d A l b u m ,   d e s t i n a t i o n F o l d e r )   { 
 	 l e t   u n p a c k e d A l b u m ; 
 	 
 	 / /   C r e a t e   a l b u m 
 	 i f   ( d e s t i n a t i o n F o l d e r )   { 
 	 	 p h o t o s A p p . m a k e ( { n e w :   ' a l b u m ' ,   n a m e d :   p a c k e d A l b u m . n a m e ,   a t :   d e s t i n a t i o n F o l d e r } ) ; 
 	 	 u n p a c k e d A l b u m   =   d e s t i n a t i o n F o l d e r . a l b u m s . b y N a m e ( p a c k e d A l b u m . n a m e ) ; 
 	 }   e l s e   { 
 	 	 p h o t o s A p p . m a k e ( { n e w :   ' a l b u m ' ,   n a m e d :   p a c k e d A l b u m . n a m e } ) ; 
 	 	 u n p a c k e d A l b u m   =   p h o t o s A p p . a l b u m s . b y N a m e ( p a c k e d A l b u m . n a m e ) ; 
 	 } 
 	 
 	 / /   A d d   i t e m s 
 	 c o n s t   p r o c e s s e d I t e m s   =   p a c k e d A l b u m . c h i l d r e n . m a p ( i t e m I d   = >   { 
 	 	 c o n s t   i t e m   =   p h o t o s A p p . m e d i a I t e m s . b y I d ( i t e m I d ) ; 
 	 	 
 	 	 t r y   { 
 	 	 	 i t e m . i d ( ) ; 
 	 	 	 r e t u r n   i t e m ; 
 	 	 }   c a t c h   ( e )   { 
 	 	 	 r e t u r n   i t e m I d ; 
 	 	 } 
 	 } ) ; 
 	 
 	 c o n s t   c h i l d I t e m s   =   p r o c e s s e d I t e m s . f i l t e r ( i t e m   = >   ( t y p e o f   i t e m )   ! = =   ' s t r i n g ' ) ; 
 	 c o n s t   m i s s i n g I t e m s   =   p r o c e s s e d I t e m s . f i l t e r ( i t e m   = >   ( t y p e o f   i t e m )   = = =   ' s t r i n g ' ) ; 
 	 
 	 p h o t o s A p p . a d d ( c h i l d I t e m s ,   { t o :   u n p a c k e d A l b u m } ) ; 
 	 
 	 r e t u r n   m i s s i n g I t e m s ; 
 } 
 
 f u n c t i o n   w h i l e R e p o r t i n g P r o g r e s s ( i n i t i a l P r o g r e s s T e x t   ,   c a l l b a c k )   { 
 	 p h o t o s A p p . m a k e ( { n e w :   ' a l b u m ' ,   n a m e d :   i n i t i a l P r o g r e s s T e x t } ) ; 
 	 c o n s t   e p h e m e r a l P r o g r e s s A l b u m   =   p h o t o s A p p . a l b u m s . b y N a m e ( i n i t i a l P r o g r e s s T e x t ) ; 
 	 c o n s t   p r o g r e s s A l b u m   =   p h o t o s A p p . a l b u m s . b y I d ( e p h e m e r a l P r o g r e s s A l b u m . i d ( ) ) ; 
 	 
 	 t r y   { 
 	 	 c a l l b a c k ( p r o g r e s s T e x t   = >   { 
 	 	 	 p r o g r e s s A l b u m . n a m e   =   p r o g r e s s T e x t ; 
 	 	 } ) ; 
 	 }   c a t c h   ( e r r o r )   { 
 	 	 t h r o w   e r r o r ; 
 	 }   f i n a l l y   { 	 
 	 	 p h o t o s A p p . d e l e t e ( p r o g r e s s A l b u m ) ; 
 	 } 
 } 
 
 f u n c t i o n   t o P r o p e r A r r a y ( a u t o m a t i o n A r r a y )   { 
 	 l e t   r e s u l t   =   [ ] ; 
 	 
 	 f o r   ( l e t   i   =   0 ;   i   <   a u t o m a t i o n A r r a y . l e n g t h ;   i + + )   { 
 	 	 r e s u l t . p u s h ( a u t o m a t i o n A r r a y [ i ] ) ; 
 	 } 
 	 
 	 r e t u r n   r e s u l t ; 
 } 
 
 f u n c t i o n   i s A l b u m ( v a l u e )   { 
 	 t r y   { 
 	 	 v a l u e . m e d i a I t e m s ( ) ; 
 	 	 r e t u r n   t r u e ; 
 	 }   c a t c h ( e )   { 
 	 	 r e t u r n   f a l s e ; 
 	 } 
 } 
 
 f u n c t i o n   l o g ( v a l u e )   { 
 	 c o n s t   s t r i n g i f i e d V a l u e   =   J S O N . s t r i n g i f y ( v a l u e ) ; 
 	 s c r i p t A p p . d i s p l a y A l e r t ( s t r i n g i f i e d V a l u e   = = =   u n d e f i n e d   ?   ' u n d e f i n e d '   :   s t r i n g i f i e d V a l u e ) ; 
 } 
 
 / /   R u n 
 c o n s t   p h o t o s A p p   =   A p p l i c a t i o n ( ' P h o t o s ' ) ; 
 c o n s t   s c r i p t A p p   =   A p p l i c a t i o n . c u r r e n t A p p l i c a t i o n ( ) ; 
 s c r i p t A p p . i n c l u d e S t a n d a r d A d d i t i o n s   =   t r u e ; 
 
 / /   / /   A s k   f o r   s o u r c e   n a m e 
 l e t   t o P a c k N a m e s   =   [ ] ; 
 c o n s t   n a m e D i a l o g R e s u l t   =   s c r i p t A p p . d i s p l a y D i a l o g ( ' E n t e r   t h e   n a m e   o f   t h e   f o l d e r   t o   s c a n . ' ,   { 
 	 d e f a u l t A n s w e r :   ' ' , 
 	 b u t t o n s :   [ ' C a n c e l ' ,   ' S c a n   f o l d e r ' ] , 
 	 d e f a u l t B u t t o n :   ' S c a n   f o l d e r ' , 
 	 c a n c e l B u t t o n :   ' C a n c e l ' 
 } ) ; 
 
 i f   ( n a m e D i a l o g R e s u l t . b u t t o n R e t u r n e d   = = =   ' S c a n   f o l d e r ' )   { 
 	 t o P a c k N a m e s . p u s h ( n a m e D i a l o g R e s u l t . t e x t R e t u r n e d ) ; 
 } 
 
 / /   / /   A n n o u n c e   t a s k 
 / * 
 c o n s t   p l u r a l i z e d F o l d e r s   =   t o P a c k N a m e s . l e n g t h   = = =   1   ?   ' f o l d e r   i s '   :   ' f o l d e r s   a r e ' ; 
 c o n s t   f o r m a t t e d F o l d e r L i s t   =   t o P a c k N a m e s . r e d u c e ( ( a c c u m u l a t e d L i s t ,   n a m e ,   n a m e I n d e x ,   a l l N a m e s )   = >   { 
 	 c o n s t   q u o t e d N a m e   =   `  $ { n a m e }  ` ; 
 	 c o n s t   s e p a r a t o r   =   ( n a m e I n d e x   <   a l l N a m e s . l e n g t h   -   1 )   ?   ' ,   '   :   '   a n d   ' ; 
 	 r e t u r n   ( n a m e I n d e x   = = =   0 )   ?   q u o t e d N a m e   :   ` $ { a c c u m u l a t e d L i s t } $ { s e p a r a t o r } $ { q u o t e d N a m e } ` ; 
 } ,   ' ' ) ; 
 s c r i p t A p p . d i s p l a y A l e r t ( ` Y o u r   p h o t o   l i b r a r y   w i l l   n o w   b e   s c a n n e d   f o r   p h o t o s . \ n T h e   s p e c i f i e d   $ { p l u r a l i z e d F o l d e r s }   $ { f o r m a t t e d F o l d e r L i s t } . ` ) ; 
 * / 
 
 
 / /   / /   D o 
 i f   ( t o P a c k N a m e s . l e n g t h   >   0 )   { 
 	 / /   R e a d   a l b u m   s t r u c t u r e 	 
 	 l e t   p a c k e d F o l d e r s ; 
 	 w h i l e R e p o r t i n g P r o g r e s s ( ' R e a d i n g & ' ,   r e p o r t P r o g r e s s   = >   { 
 	 	 l e t   p a c k e d P h o t o C o u n t   =   0 ; 
 	 	 p a c k e d F o l d e r s   =   p a c k R o o t F o l d e r s B y N a m e ( t o P a c k N a m e s ,   n e w l y P a c k e d I t e m C o u n t   = >   { 
 	 	 	 p a c k e d P h o t o C o u n t   + =   n e w l y P a c k e d I t e m C o u n t ; 
 	 	 	 r e p o r t P r o g r e s s ( ` R e a d i n g &   ( $ { p a c k e d P h o t o C o u n t }   f o u n d ) ` ) ; 
 	 	 } ) ; 
 	 } ) ; 
 
 	 / /   P r o m p t   t o   s w i t c h   l i b r a r i e s 
 	 c o n s t   p h a s e 2 D i a l o g R e s u l t   =   s c r i p t A p p . d i s p l a y D i a l o g ( ' F o l d e r s   s u c c e s s f u l l y   s c a n n e d .   N o w ,   p l e a s e   o p e n   t h e   t a r g e t   l i b r a r y ,   t h e n   c l i c k   O K   t o   s t a r t   i m p o r t i n g . ' ,   { 
 	 	 b u t t o n s :   [ " C a n c e l " ,   " I m p o r t " ] , 
 	 	 d e f a u l t B u t t o n :   " I m p o r t " , 
 	 	 c a n c e l B u t t o n :   " C a n c e l " 
 	 } ) ; 
 	 
 	 i f   ( p h a s e 2 D i a l o g R e s u l t . b u t t o n R e t u r n e d   = = =   ' I m p o r t ' )   { 
 	 	 / /   U n p a c k   f o l d e r s 
 	 	 c o n s t   m i s s i n g I t e m s   =   u n p a c k R o o t F o l d e r s ( p a c k e d F o l d e r s ) ; 
 	 
 	 	 / /   R e p o r t   m i s s i n g   i t e m s 
 	 	 i f   ( m i s s i n g I t e m s . l e n g t h   = = =   0 )   { 
 	 	 	 s c r i p t A p p . d i s p l a y A l e r t ( ' F o l d e r s   s u c c e s s f u l l y   r e s t o r e d ! ' ) ; 
 	 	 }   e l s e   { 
 	 	 	 c o n s t   m i s s i n g I t e m s S t r i n g   =   ( m i s s i n g I t e m s . l e n g t h   = = =   1 )   ? 
 	 	 	 	 ' 1   i t e m   i s '   : 
 	 	 	 	 ` $ { m i s s i n g I t e m s . l e n g t h }   i t e m s   a r e ` ; 
 	 	 
 	 	 	 c o n s t   m i s s i n g I t e m s T e x t   =   ` F o l d e r s   r e s t o r e d . \ n $ { m i s s i n g I t e m s S t r i n g }   m i s s i n g .   T o   d i s p l a y 	   t h e   m i s s i n g   i t e m s ,   p l e a s e   o p e n   t h e   s o u r c e   l i b r a r y   a g a i n ,   t h e n   c l i c k   S h o w . ` ; 
 	 	 
 	 	 	 c o n s t   m i s s i n g I t e m s D i a l o g R e s u l t   =   s c r i p t A p p . d i s p l a y D i a l o g ( m i s s i n g I t e m s T e x t ,   { 
 	 	 	 	 b u t t o n s :   [ " D o n e " ,   " S h o w " ] , 
 	 	 	 	 d e f a u l t B u t t o n :   " S h o w " , 
 	 	 	 	 c a n c e l B u t t o n :   " D o n e " 
 	 	 	 } ) ; 
 	 	 
 	 	 	 i f   ( m i s s i n g I t e m s D i a l o g R e s u l t . b u t t o n R e t u r n e d   = = =   ' S h o w ' )   { 
 	 	 	 	 c o n s t   m i s s i n g I t e m s A l b u m   =   { 
 	 	 	 	 	 t y p e :   ' a l b u m ' , 
 	 	 	 	 	 n a m e :   ''S   M i s s i n g   i t e m s ' , 
 	 	 	 	 	 c h i l d r e n :   m i s s i n g I t e m s 
 	 	 	 	 } ; 
 	 	 	 
 	 	 	 	 u n p a c k A l b u m ( m i s s i n g I t e m s A l b u m ) ; 
 	 	 	 } 
 	 	 } 
 	 } 
 } 
                              7�jscr  ��ޭ