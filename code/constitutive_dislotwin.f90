! Copyright 2011 Max-Planck-Institut für Eisenforschung GmbH
!
! This file is part of DAMASK,
! the Düsseldorf Advanced MAterial Simulation Kit.
!
! DAMASK is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! DAMASK is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with DAMASK. If not, see <http://www.gnu.org/licenses/>.
!
 ! # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
 ! *   $ I d :   c o n s t i t u t i v e _ d i s l o t w i n . f 9 0   8 3 4   2 0 1 1 - 0 4 - 0 4   1 4 : 0 9 : 5 4 Z   M P I E \ f . r o t e r s   $ 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 ! *             M o d u l e :   C O N S T I T U T I V E                 * 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 
 M O D U L E   c o n s t i t u t i v e _ d i s l o t w i n 
 
 ! *   I n c l u d e   o t h e r   m o d u l e s 
 u s e   p r e c ,   o n l y :   p R e a l , p I n t 
 i m p l i c i t   n o n e 
 
 ! *   L i s t s   o f   s t a t e s   a n d   p h y s i c a l   p a r a m e t e r s 
 c h a r a c t e r ( l e n = * ) ,   p a r a m e t e r   : :   c o n s t i t u t i v e _ d i s l o t w i n _ l a b e l   =   ' d i s l o t w i n ' 
 c h a r a c t e r ( l e n = 1 8 ) ,   d i m e n s i o n ( 2 ) ,   p a r a m e t e r : :   c o n s t i t u t i v e _ d i s l o t w i n _ l i s t B a s i c S l i p S t a t e s   =   ( / ' r h o E d g e       ' ,   & 
                                                                                                                                                                                         ' r h o E d g e D i p ' / ) 
 c h a r a c t e r ( l e n = 1 8 ) ,   d i m e n s i o n ( 1 ) ,   p a r a m e t e r : :   c o n s t i t u t i v e _ d i s l o t w i n _ l i s t B a s i c T w i n S t a t e s   =   ( / ' t w i n F r a c t i o n ' / ) 
 c h a r a c t e r ( l e n = 1 8 ) ,   d i m e n s i o n ( 4 ) ,   p a r a m e t e r : :   c o n s t i t u t i v e _ d i s l o t w i n _ l i s t D e p e n d e n t S l i p S t a t e s   = ( / ' i n v L a m b d a S l i p         ' ,   & 
                                                                                                                                                                                               ' i n v L a m b d a S l i p T w i n ' ,   & 
                                                                                                                                                                                               ' m e a n F r e e P a t h S l i p   ' ,   & 
                                                                                                                                                                                               ' t a u S l i p T h r e s h o l d   ' / ) 
 c h a r a c t e r ( l e n = 1 8 ) ,   d i m e n s i o n ( 4 ) ,   p a r a m e t e r : :   c o n s t i t u t i v e _ d i s l o t w i n _ l i s t D e p e n d e n t T w i n S t a t e s   = ( / ' i n v L a m b d a T w i n       ' ,   & 
                                                                                                                                                                                               ' m e a n F r e e P a t h T w i n ' ,   & 
                                                                                                                                                                                               ' t a u T w i n T h r e s h o l d ' ,   & 
                                                                                                                                                                                               ' t w i n V o l u m e             ' / ) 
 r e a l ( p R e a l ) ,   p a r a m e t e r   : :   k B   =   1 . 3 8 e - 2 3 _ p R e a l   !   B o l t z m a n n   c o n s t a n t   i n   J / K e l v i n 
 
 ! *   D e f i n i t i o n   o f   g l o b a l   v a r i a b l e s 
 i n t e g e r ( p I n t ) ,   d i m e n s i o n ( : ) ,   a l l o c a t a b l e   : :                               c o n s t i t u t i v e _ d i s l o t w i n _ s i z e D o t S t a t e ,   &                                 !   n u m b e r   o f   d o t S t a t e s 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ s i z e S t a t e ,   &                                       !   t o t a l   n u m b e r   o f   m i c r o s t r u c t u r a l   s t a t e   v a r i a b l e s 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ s i z e P o s t R e s u l t s                                 !   c u m u l a t i v e   s i z e   o f   p o s t   r e s u l t s 
 i n t e g e r ( p I n t ) ,   d i m e n s i o n ( : , : ) ,   a l l o c a t a b l e ,   t a r g e t   : :           c o n s t i t u t i v e _ d i s l o t w i n _ s i z e P o s t R e s u l t                                   !   s i z e   o f   e a c h   p o s t   r e s u l t   o u t p u t 
 c h a r a c t e r ( l e n = 6 4 ) ,   d i m e n s i o n ( : , : ) ,   a l l o c a t a b l e ,   t a r g e t   : :   c o n s t i t u t i v e _ d i s l o t w i n _ o u t p u t                                                   !   n a m e   o f   e a c h   p o s t   r e s u l t   o u t p u t 
 c h a r a c t e r ( l e n = 3 2 ) ,   d i m e n s i o n ( : ) ,   a l l o c a t a b l e   : :                       c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e N a m e                                     !   n a m e   o f   t h e   l a t t i c e   s t r u c t u r e 
 i n t e g e r ( p I n t ) ,   d i m e n s i o n ( : ) ,   a l l o c a t a b l e   : :                               c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e ,   &                                       !   n u m b e r   r e p r e s e n t i n g   t h e   k i n d   o f   l a t t i c e   s t r u c t u r e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ,   &                                     !   t o t a l   n u m b e r   o f   a c t i v e   s l i p   s y s t e m s   f o r   e a c h   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n                                           !   t o t a l   n u m b e r   o f   a c t i v e   t w i n   s y s t e m s   f o r   e a c h   i n s t a n c e 
 i n t e g e r ( p I n t ) ,   d i m e n s i o n ( : , : ) ,   a l l o c a t a b l e   : :                           c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ,   &                                               !   n u m b e r   o f   a c t i v e   s l i p   s y s t e m s   f o r   e a c h   f a m i l y   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ,   &                                               !   n u m b e r   o f   a c t i v e   t w i n   s y s t e m s   f o r   e a c h   f a m i l y   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ s l i p F a m i l y ,   &                                     !   l o o k u p   t a b l e   r e l a t i n g   a c t i v e   s l i p   s y s t e m   t o   s l i p   f a m i l y   f o r   e a c h   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ t w i n F a m i l y ,   &                                     !   l o o k u p   t a b l e   r e l a t i n g   a c t i v e   t w i n   s y s t e m   t o   t w i n   f a m i l y   f o r   e a c h   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ s l i p S y s t e m L a t t i c e ,   &                       !   l o o k u p   t a b l e   r e l a t i n g   a c t i v e   s l i p   s y s t e m   i n d e x   t o   l a t t i c e   s l i p   s y s t e m   i n d e x   f o r   e a c h   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ t w i n S y s t e m L a t t i c e                             !   l o o k u p   t a b l e   r e l a t i n g   a c t i v e   t w i n   s y s t e m   i n d e x   t o   l a t t i c e   t w i n   s y s t e m   i n d e x   f o r   e a c h   i n s t a n c e 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( : ) ,   a l l o c a t a b l e   : :                                   c o n s t i t u t i v e _ d i s l o t w i n _ C o v e r A ,   &                                             !   c / a   r a t i o   f o r   h e x   t y p e   l a t t i c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ C 1 1 ,   &                                                   !   C 1 1   e l e m e n t   i n   e l a s t i c i t y   m a t r i x 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ C 1 2 ,   &                                                   !   C 1 2   e l e m e n t   i n   e l a s t i c i t y   m a t r i x 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ C 1 3 ,   &                                                   !   C 1 3   e l e m e n t   i n   e l a s t i c i t y   m a t r i x 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ C 3 3 ,   &                                                   !   C 3 3   e l e m e n t   i n   e l a s t i c i t y   m a t r i x 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ C 4 4 ,   &                                                   !   C 4 4   e l e m e n t   i n   e l a s t i c i t y   m a t r i x 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ G m o d ,   &                                                 !   s h e a r   m o d u l u s 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ C A t o m i c V o l u m e ,   &                               !   a t o m i c   v o l u m e   i n   B u g e r s   v e c t o r   u n i t 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ D 0 ,   &                                                     !   p r e f a c t o r   f o r   s e l f - d i f f u s i o n   c o e f f i c i e n t 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ Q s d ,   &                                                   !   a c t i v a t i o n   e n e r g y   f o r   d i s l o c a t i o n   c l i m b 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e ,   &                                       !   g r a i n   s i z e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ p ,   &                                                       !   p - e x p o n e n t   i n   g l i d e   v e l o c i t y 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ q ,   &                                                       !   q - e x p o n e n t   i n   g l i d e   v e l o c i t y 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ M a x T w i n F r a c t i o n ,   &                           !   m a x i m u m   a l l o w e d   t o t a l   t w i n   v o l u m e   f r a c t i o n 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ r ,   &                                                       !   r - e x p o n e n t   i n   t w i n   n u c l e a t i o n   r a t e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ C E d g e D i p M i n D i s t a n c e ,   &                   ! 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ C m f p t w i n ,   &                                         ! 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ C t h r e s h o l d t w i n ,   &                             ! 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ S o l i d S o l u t i o n S t r e n g t h ,   &               !   S t r e n g t h   d u e   t o   e l e m e n t s   i n   s o l i d   s o l u t i o n 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ L 0 ,   &                                                     !   L e n g t h   o f   t w i n   n u c l e i   i n   B u r g e r s   v e c t o r s 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ a T o l R h o                                                 !   a b s o l u t e   t o l e r a n c e   f o r   i n t e g r a t i o n   o f   d i s l o c a t i o n   d e n s i t y 
 r e a l ( p R e a l ) ,               d i m e n s i o n ( : , : , : ) ,               a l l o c a t a b l e   : :   c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6                                               !   e l a s t i c i t y   m a t r i x   i n   M a n d e l   n o t a t i o n   f o r   e a c h   i n s t a n c e 
 r e a l ( p R e a l ) ,               d i m e n s i o n ( : , : , : , : ) ,           a l l o c a t a b l e   : :   c o n s t i t u t i v e _ d i s l o t w i n _ C t w i n _ 6 6                                               !   t w i n   e l a s t i c i t y   m a t r i x   i n   M a n d e l   n o t a t i o n   f o r   e a c h   i n s t a n c e 
 r e a l ( p R e a l ) ,               d i m e n s i o n ( : , : , : , : , : ) ,       a l l o c a t a b l e   : :   c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 3 3 3 3                                           !   e l a s t i c i t y   m a t r i x   f o r   e a c h   i n s t a n c e 
 r e a l ( p R e a l ) ,               d i m e n s i o n ( : , : , : , : , : , : ) ,   a l l o c a t a b l e   : :   c o n s t i t u t i v e _ d i s l o t w i n _ C t w i n _ 3 3 3 3                                           !   t w i n   e l a s t i c i t y   m a t r i x   f o r   e a c h   i n s t a n c e 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( : , : ) ,   a l l o c a t a b l e   : :                               c o n s t i t u t i v e _ d i s l o t w i n _ r h o E d g e 0 ,   &                                         !   i n i t i a l   e d g e   d i s l o c a t i o n   d e n s i t y   p e r   s l i p   s y s t e m   f o r   e a c h   f a m i l y   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ r h o E d g e D i p 0 ,   &                                   !   i n i t i a l   e d g e   d i p o l e   d e n s i t y   p e r   s l i p   s y s t e m   f o r   e a c h   f a m i l y   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p F a m i l y ,   &                 !   a b s o l u t e   l e n g t h   o f   b u r g e r s   v e c t o r   [ m ]   f o r   e a c h   s l i p   f a m i l y   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ,   &                 !   a b s o l u t e   l e n g t h   o f   b u r g e r s   v e c t o r   [ m ]   f o r   e a c h   s l i p   s y s t e m   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r T w i n F a m i l y ,   &                 !   a b s o l u t e   l e n g t h   o f   b u r g e r s   v e c t o r   [ m ]   f o r   e a c h   t w i n   f a m i l y   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r T w i n S y s t e m ,   &                 !   a b s o l u t e   l e n g t h   o f   b u r g e r s   v e c t o r   [ m ]   f o r   e a c h   t w i n   s y s t e m   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p F a m i l y ,   &                     !   a c t i v a t i o n   e n e r g y   f o r   g l i d e   [ J ]   f o r   e a c h   s l i p   f a m i l y   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p S y s t e m ,   &                     !   a c t i v a t i o n   e n e r g y   f o r   g l i d e   [ J ]   f o r   e a c h   s l i p   s y s t e m   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p F a m i l y ,   &                           !   d i s l o c a t i o n   v e l o c i t y   p r e f a c t o r   [ m / s ]   f o r   e a c h   f a m i l y   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p S y s t e m ,   &                           !   d i s l o c a t i o n   v e l o c i t y   p r e f a c t o r   [ m / s ]   f o r   e a c h   s l i p   s y s t e m   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n F a m i l y ,   &                     !   t w i n   n u c l e a t i o n   r a t e   [ 1 / m � s ]   f o r   e a c h   t w i n   f a m i l y   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n S y s t e m ,   &                     !   t w i n   n u c l e a t i o n   r a t e   [ 1 / m � s ]   f o r   e a c h   t w i n   s y s t e m   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ t w i n s i z e P e r T w i n F a m i l y ,   &               !   t w i n   t h i c k n e s s   [ m ]   f o r   e a c h   t w i n   f a m i l y   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ t w i n s i z e P e r T w i n S y s t e m ,   &               !   t w i n   t h i c k n e s s   [ m ]   f o r   e a c h   t w i n   s y s t e m   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ C L a m b d a S l i p P e r S l i p F a m i l y ,   &         !   A d j .   p a r a m e t e r   f o r   d i s t a n c e   b e t w e e n   2   f o r e s t   d i s l o c a t i o n s   f o r   e a c h   s l i p   f a m i l y   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ C L a m b d a S l i p P e r S l i p S y s t e m ,   &         !   A d j .   p a r a m e t e r   f o r   d i s t a n c e   b e t w e e n   2   f o r e s t   d i s l o c a t i o n s   f o r   e a c h   s l i p   s y s t e m   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n S l i p S l i p ,   &                   !   c o e f f i c i e n t s   f o r   s l i p - s l i p   i n t e r a c t i o n   f o r   e a c h   i n t e r a c t i o n   t y p e   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n S l i p T w i n ,   &                   !   c o e f f i c i e n t s   f o r   s l i p - t w i n   i n t e r a c t i o n   f o r   e a c h   i n t e r a c t i o n   t y p e   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n T w i n S l i p ,   &                   !   c o e f f i c i e n t s   f o r   t w i n - s l i p   i n t e r a c t i o n   f o r   e a c h   i n t e r a c t i o n   t y p e   a n d   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n T w i n T w i n                         !   c o e f f i c i e n t s   f o r   t w i n - t w i n   i n t e r a c t i o n   f o r   e a c h   i n t e r a c t i o n   t y p e   a n d   i n s t a n c e 
 r e a l ( p R e a l ) ,               d i m e n s i o n ( : , : , : ) ,               a l l o c a t a b l e   : :   c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x S l i p S l i p ,   &       !   i n t e r a c t i o n   m a t r i x   o f   t h e   d i f f e r e n t   s l i p   s y s t e m s   f o r   e a c h   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x S l i p T w i n ,   &       !   i n t e r a c t i o n   m a t r i x   o f   s l i p   s y s t e m s   w i t h   t w i n   s y s t e m s   f o r   e a c h   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x T w i n S l i p ,   &       !   i n t e r a c t i o n   m a t r i x   o f   t w i n   s y s t e m s   w i t h   s l i p   s y s t e m s   f o r   e a c h   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x T w i n T w i n ,   &       !   i n t e r a c t i o n   m a t r i x   o f   t h e   d i f f e r e n t   t w i n   s y s t e m s   f o r   e a c h   i n s t a n c e 
                                                                                                                     c o n s t i t u t i v e _ d i s l o t w i n _ f o r e s t P r o j e c t i o n E d g e                       !   m a t r i x   o f   f o r e s t   p r o j e c t i o n s   o f   e d g e   d i s l o c a t i o n s   f o r   e a c h   i n s t a n c e 
 C O N T A I N S 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 ! *   -   c o n s t i t u t i v e _ d i s l o t w i n _ i n i t 
 ! *   -   c o n s t i t u t i v e _ d i s l o t w i n _ s t a t e I n i t 
 ! *   -   c o n s t i t u t i v e _ d i s l o t w i n _ r e l e v a n t S t a t e 
 ! *   -   c o n s t i t u t i v e _ d i s l o t w i n _ h o m o g e n i z e d C 
 ! *   -   c o n s t i t u t i v e _ d i s l o t w i n _ m i c r o s t r u c t u r e 
 ! *   -   c o n s t i t u t i v e _ d i s l o t w i n _ L p A n d I t s T a n g e n t 
 ! *   -   c o n s i s t u t i v e _ d i s l o t w i n _ d o t S t a t e 
 ! *   -   c o n s t i t u t i v e _ d i s l o t w i n _ d o t T e m p e r a t u r e 
 ! *   -   c o n s i s t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 
 s u b r o u t i n e   c o n s t i t u t i v e _ d i s l o t w i n _ i n i t ( f i l e ) 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 ! *             M o d u l e   i n i t i a l i z a t i o n                   * 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 u s e   p r e c ,         o n l y :   p I n t , p R e a l 
 u s e   m a t h ,         o n l y :   m a t h _ M a n d e l 3 3 3 3 t o 6 6 , m a t h _ V o i g t 6 6 t o 3 3 3 3 , m a t h _ m u l 3 x 3 
 u s e   I O 
 u s e   m a t e r i a l 
 u s e   l a t t i c e 
 
 ! *   I n p u t   v a r i a b l e s 
 i n t e g e r ( p I n t ) ,   i n t e n t ( i n )   : :   f i l e 
 ! *   L o c a l   v a r i a b l e s 
 i n t e g e r ( p I n t ) ,   p a r a m e t e r   : :   m a x N c h u n k s   =   2 1 
 i n t e g e r ( p I n t ) ,   d i m e n s i o n ( 1 + 2 * m a x N c h u n k s )   : :   p o s i t i o n s 
 i n t e g e r ( p I n t )   s e c t i o n , m a x N i n s t a n c e , f , i , j , k , l , m , n , o , p , q , r , s , s 1 , s 2 , t 1 , t 2 , n s , n t , o u t p u t , m y S i z e , m y S t r u c t u r e , m a x T o t a l N s l i p , m a x T o t a l N t w i n 
 c h a r a c t e r ( l e n = 6 4 )   t a g 
 c h a r a c t e r ( l e n = 1 0 2 4 )   l i n e 
 
 ! $ O M P   C R I T I C A L   ( w r i t e 2 o u t ) 
     w r i t e ( 6 , * ) 
     w r i t e ( 6 , ' ( a 2 0 , a 2 0 , a 1 2 ) ' )   ' < < < + -     c o n s t i t u t i v e _ ' , c o n s t i t u t i v e _ d i s l o t w i n _ l a b e l , '   i n i t     - + > > > ' 
     w r i t e ( 6 , * )   ' $ I d :   c o n s t i t u t i v e _ d i s l o t w i n . f 9 0   8 3 4   2 0 1 1 - 0 4 - 0 4   1 4 : 0 9 : 5 4 Z   M P I E \ f . r o t e r s   $ ' 
     w r i t e ( 6 , * ) 
 ! $ O M P   E N D   C R I T I C A L   ( w r i t e 2 o u t ) 
 
 m a x N i n s t a n c e   =   c o u n t ( p h a s e _ c o n s t i t u t i o n   = =   c o n s t i t u t i v e _ d i s l o t w i n _ l a b e l ) 
 i f   ( m a x N i n s t a n c e   = =   0 )   r e t u r n 
 
 ! *   S p a c e   a l l o c a t i o n   f o r   g l o b a l   v a r i a b l e s 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ s i z e D o t S t a t e ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ s i z e S t a t e ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ s i z e P o s t R e s u l t s ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ s i z e P o s t R e s u l t ( m a x v a l ( p h a s e _ N o u t p u t ) , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ o u t p u t ( m a x v a l ( p h a s e _ N o u t p u t ) , m a x N i n s t a n c e ) ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ s i z e D o t S t a t e         =   0 _ p I n t 
 c o n s t i t u t i v e _ d i s l o t w i n _ s i z e S t a t e               =   0 _ p I n t 
 c o n s t i t u t i v e _ d i s l o t w i n _ s i z e P o s t R e s u l t s   =   0 _ p I n t 
 c o n s t i t u t i v e _ d i s l o t w i n _ s i z e P o s t R e s u l t     =   0 _ p I n t 
 c o n s t i t u t i v e _ d i s l o t w i n _ o u t p u t                     =   ' ' 
 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e N a m e ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( l a t t i c e _ m a x N s l i p F a m i l y , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ( l a t t i c e _ m a x N t w i n F a m i l y , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ s l i p F a m i l y ( l a t t i c e _ m a x N s l i p , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ t w i n F a m i l y ( l a t t i c e _ m a x N t w i n , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ s l i p S y s t e m L a t t i c e ( l a t t i c e _ m a x N s l i p , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ t w i n S y s t e m L a t t i c e ( l a t t i c e _ m a x N t w i n , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( m a x N i n s t a n c e ) ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e N a m e           =   ' ' 
 c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e                   =   0 _ p I n t 
 c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p                           =   0 _ p I n t 
 c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n                           =   0 _ p I n t 
 c o n s t i t u t i v e _ d i s l o t w i n _ s l i p F a m i l y                 =   0 _ p I n t 
 c o n s t i t u t i v e _ d i s l o t w i n _ t w i n F a m i l y                 =   0 _ p I n t 
 c o n s t i t u t i v e _ d i s l o t w i n _ s l i p S y s t e m L a t t i c e   =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ t w i n S y s t e m L a t t i c e   =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p                 =   0 _ p I n t 
 c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n                 =   0 _ p I n t 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C o v e r A ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C 1 1 ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C 1 2 ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C 1 3 ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C 3 3 ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C 4 4 ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ G m o d ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C A t o m i c V o l u m e ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ D 0 ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ Q s d ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ p ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ q ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ M a x T w i n F r a c t i o n ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ r ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C E d g e D i p M i n D i s t a n c e ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C m f p t w i n ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C t h r e s h o l d t w i n ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ S o l i d S o l u t i o n S t r e n g t h ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ L 0 ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ a T o l R h o ( m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 6 , 6 , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 3 3 3 3 ( 3 , 3 , 3 , 3 , m a x N i n s t a n c e ) ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ C o v e r A                               =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C 1 1                                     =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C 1 2                                     =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C 1 3                                     =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C 3 3                                     =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C 4 4                                     =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ G m o d                                   =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C A t o m i c V o l u m e                 =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ D 0                                       =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ Q s d                                     =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e                         =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ p                                         =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ q                                         =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ M a x T w i n F r a c t i o n             =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ r                                         =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C E d g e D i p M i n D i s t a n c e     =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C m f p t w i n                           =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C t h r e s h o l d t w i n               =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ S o l i d S o l u t i o n S t r e n g t h =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ L 0                                       =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ a T o l R h o                             =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6                           =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 3 3 3 3                       =   0 . 0 _ p R e a l 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ r h o E d g e 0 ( l a t t i c e _ m a x N s l i p F a m i l y , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ r h o E d g e D i p 0 ( l a t t i c e _ m a x N s l i p F a m i l y , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p F a m i l y ( l a t t i c e _ m a x N s l i p F a m i l y , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r T w i n F a m i l y ( l a t t i c e _ m a x N t w i n F a m i l y , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p F a m i l y ( l a t t i c e _ m a x N s l i p F a m i l y , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p F a m i l y ( l a t t i c e _ m a x N s l i p F a m i l y , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n F a m i l y ( l a t t i c e _ m a x N t w i n F a m i l y , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ t w i n s i z e P e r T w i n F a m i l y ( l a t t i c e _ m a x N t w i n F a m i l y , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C L a m b d a S l i p P e r S l i p F a m i l y ( l a t t i c e _ m a x N s l i p F a m i l y , m a x N i n s t a n c e ) ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ r h o E d g e 0                                   =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ r h o E d g e D i p 0                             =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p F a m i l y           =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r T w i n F a m i l y           =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p F a m i l y               =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p F a m i l y                     =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n F a m i l y               =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ t w i n s i z e P e r T w i n F a m i l y         =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C L a m b d a S l i p P e r S l i p F a m i l y   =   0 . 0 _ p R e a l 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n S l i p S l i p ( l a t t i c e _ m a x N i n t e r a c t i o n , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n S l i p T w i n ( l a t t i c e _ m a x N i n t e r a c t i o n , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n T w i n S l i p ( l a t t i c e _ m a x N i n t e r a c t i o n , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n T w i n T w i n ( l a t t i c e _ m a x N i n t e r a c t i o n , m a x N i n s t a n c e ) ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n S l i p S l i p   =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n S l i p T w i n   =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n T w i n S l i p   =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n T w i n T w i n   =   0 . 0 _ p R e a l 
 
 ! *   R e a d o u t   d a t a   f r o m   m a t e r i a l . c o n f i g   f i l e 
 r e w i n d ( f i l e ) 
 l i n e   =   ' ' 
 s e c t i o n   =   0 
 
 d o   w h i l e   ( I O _ l c ( I O _ g e t T a g ( l i n e , ' < ' , ' > ' ) )   / =   ' p h a s e ' )           !   w i n d   f o r w a r d   t o   < p h a s e > 
       r e a d ( f i l e , ' ( a 1 0 2 4 ) ' , E N D = 1 0 0 )   l i n e 
 e n d d o 
 
 d o                                                                                                               !   r e a d   t h r u   s e c t i o n s   o f   p h a s e   p a r t 
       r e a d ( f i l e , ' ( a 1 0 2 4 ) ' , E N D = 1 0 0 )   l i n e 
       i f   ( I O _ i s B l a n k ( l i n e ) )   c y c l e                                                         !   s k i p   e m p t y   l i n e s 
       i f   ( I O _ g e t T a g ( l i n e , ' < ' , ' > ' )   / =   ' ' )   e x i t                                 !   s t o p   a t   n e x t   p a r t 
       i f   ( I O _ g e t T a g ( l i n e , ' [ ' , ' ] ' )   / =   ' ' )   t h e n                                 !   n e x t   s e c t i o n 
           s e c t i o n   =   s e c t i o n   +   1 
           o u t p u t   =   0                                                                                       !   r e s e t   o u t p u t   c o u n t e r 
       e n d i f 
       i f   ( s e c t i o n   >   0   . a n d .   p h a s e _ c o n s t i t u t i o n ( s e c t i o n )   = =   c o n s t i t u t i v e _ d i s l o t w i n _ l a b e l )   t h e n     !   o n e   o f   m y   s e c t i o n s 
           i   =   p h a s e _ c o n s t i t u t i o n I n s t a n c e ( s e c t i o n )           !   w h i c h   i n s t a n c e   o f   m y   c o n s t i t u t i o n   i s   p r e s e n t   p h a s e 
           p o s i t i o n s   =   I O _ s t r i n g P o s ( l i n e , m a x N c h u n k s ) 
           t a g   =   I O _ l c ( I O _ s t r i n g V a l u e ( l i n e , p o s i t i o n s , 1 ) )                 !   e x t r a c t   k e y 
           s e l e c t   c a s e ( t a g ) 
               c a s e   ( ' ( o u t p u t ) ' ) 
                   o u t p u t   =   o u t p u t   +   1 
                   c o n s t i t u t i v e _ d i s l o t w i n _ o u t p u t ( o u t p u t , i )   =   I O _ l c ( I O _ s t r i n g V a l u e ( l i n e , p o s i t i o n s , 2 ) ) 
               c a s e   ( ' l a t t i c e _ s t r u c t u r e ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e N a m e ( i )   =   I O _ l c ( I O _ s t r i n g V a l u e ( l i n e , p o s i t i o n s , 2 ) ) 
               c a s e   ( ' c o v e r a _ r a t i o ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ C o v e r A ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' c 1 1 ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ C 1 1 ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' c 1 2 ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ C 1 2 ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' c 1 3 ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ C 1 3 ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' c 3 3 ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ C 3 3 ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' c 4 4 ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ C 4 4 ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' n s l i p ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N s l i p F a m i l y )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( j , i )   =   I O _ i n t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' n t w i n ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N t w i n F a m i l y )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ( j , i )   =   I O _ i n t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' r h o e d g e 0 ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N s l i p F a m i l y )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ r h o E d g e 0 ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' r h o e d g e d i p 0 ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N s l i p F a m i l y )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ r h o E d g e D i p 0 ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' s l i p b u r g e r s ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N s l i p F a m i l y )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p F a m i l y ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' t w i n b u r g e r s ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N t w i n F a m i l y )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r T w i n F a m i l y ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' q e d g e ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N s l i p F a m i l y )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p F a m i l y ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' v 0 ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N s l i p F a m i l y )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p F a m i l y ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' n d o t 0 ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N t w i n F a m i l y )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n F a m i l y ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' t w i n s i z e ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N t w i n F a m i l y )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ t w i n s i z e P e r T w i n F a m i l y ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' c l a m b d a s l i p ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N s l i p F a m i l y )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ C L a m b d a S l i p P e r S l i p F a m i l y ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' g r a i n s i z e ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' m a x t w i n f r a c t i o n ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ M a x T w i n F r a c t i o n ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' p e x p o n e n t ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ p ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' q e x p o n e n t ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ q ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' r e x p o n e n t ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ r ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' d 0 ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ D 0 ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' q s d ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ Q s d ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' a t o l _ r h o ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ a T o l R h o ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' c m f p t w i n ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ C m f p t w i n ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' c t h r e s h o l d t w i n ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ C t h r e s h o l d t w i n ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' s o l i d s o l u t i o n s t r e n g t h ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ S o l i d S o l u t i o n S t r e n g t h ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' l 0 ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ L 0 ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' c e d g e d i p m i n d i s t a n c e ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ C E d g e D i p M i n D i s t a n c e ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' c a t o m i c v o l u m e ' ) 
                             c o n s t i t u t i v e _ d i s l o t w i n _ C A t o m i c V o l u m e ( i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 2 ) 
               c a s e   ( ' i n t e r a c t i o n s l i p s l i p ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N i n t e r a c t i o n )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n S l i p S l i p ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' i n t e r a c t i o n s l i p t w i n ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N i n t e r a c t i o n )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n S l i p T w i n ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' i n t e r a c t i o n t w i n s l i p ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N i n t e r a c t i o n )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n T w i n S l i p ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
               c a s e   ( ' i n t e r a c t i o n t w i n t w i n ' ) 
                             f o r a l l   ( j   =   1 : l a t t i c e _ m a x N i n t e r a c t i o n )   & 
                                 c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n T w i n T w i n ( j , i )   =   I O _ f l o a t V a l u e ( l i n e , p o s i t i o n s , 1 + j ) 
           e n d   s e l e c t 
       e n d i f 
 e n d d o 
 
 1 0 0   d o   i   =   1 , m a x N i n s t a n c e 
       c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e ( i )   =   & 
       l a t t i c e _ i n i t i a l i z e S t r u c t u r e ( c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e N a m e ( i ) , c o n s t i t u t i v e _ d i s l o t w i n _ C o v e r A ( i ) ) 
       m y S t r u c t u r e   =   c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e ( i ) 
 
       ! *   S a n i t y   c h e c k s 
       i f   ( m y S t r u c t u r e   <   1   . o r .   m y S t r u c t u r e   >   3 )                                                                 c a l l   I O _ e r r o r ( 2 0 5 ) 
       i f   ( s u m ( c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( : , i ) )   < =   0 _ p I n t )                                         c a l l   I O _ e r r o r ( 2 2 5 ) 
       i f   ( s u m ( c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ( : , i ) )   <   0 _ p I n t )                                           c a l l   I O _ e r r o r ( 2 2 5 )   ! * * * 
       d o   f   =   1 , l a t t i c e _ m a x N s l i p F a m i l y 
           i f   ( c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( f , i )   >   0 _ p I n t )   t h e n 
               i f   ( c o n s t i t u t i v e _ d i s l o t w i n _ r h o E d g e 0 ( f , i )   <   0 . 0 _ p R e a l )                                   c a l l   I O _ e r r o r ( 2 2 0 ) 
               i f   ( c o n s t i t u t i v e _ d i s l o t w i n _ r h o E d g e D i p 0 ( f , i )   <   0 . 0 _ p R e a l )                             c a l l   I O _ e r r o r ( 2 2 0 ) 
               i f   ( c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p F a m i l y ( f , i )   < =   0 . 0 _ p R e a l )         c a l l   I O _ e r r o r ( 2 2 1 ) 
               i f   ( c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p F a m i l y ( f , i )   < =   0 . 0 _ p R e a l )                   c a l l   I O _ e r r o r ( 2 2 6 ) 
           e n d i f 
       e n d d o 
       d o   f   =   1 , l a t t i c e _ m a x N t w i n F a m i l y 
           i f   ( c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( f , i )   >   0 _ p I n t )   t h e n 
               i f   ( c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r T w i n F a m i l y ( f , i )   < =   0 . 0 _ p R e a l )         c a l l   I O _ e r r o r ( 2 2 1 )   ! * * * 
               i f   ( c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n F a m i l y ( f , i )   <   0 . 0 _ p R e a l )               c a l l   I O _ e r r o r ( 2 2 6 )   ! * * * 
           e n d i f 
       e n d d o 
 !       i f   ( a n y ( c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n S l i p S l i p ( 1 : m a x v a l ( l a t t i c e _ i n t e r a c t i o n S l i p S l i p ( : , : , m y S t r u c t u r e ) ) , i )   <   1 . 0 _ p R e a l ) )   c a l l   I O _ e r r o r ( 2 2 9 ) 
       i f   ( c o n s t i t u t i v e _ d i s l o t w i n _ C A t o m i c V o l u m e ( i )   < =   0 . 0 _ p R e a l )                                   c a l l   I O _ e r r o r ( 2 3 0 ) 
       i f   ( c o n s t i t u t i v e _ d i s l o t w i n _ D 0 ( i )   < =   0 . 0 _ p R e a l )                                                         c a l l   I O _ e r r o r ( 2 3 1 ) 
       i f   ( c o n s t i t u t i v e _ d i s l o t w i n _ Q s d ( i )   < =   0 . 0 _ p R e a l )                                                       c a l l   I O _ e r r o r ( 2 3 2 ) 
       i f   ( c o n s t i t u t i v e _ d i s l o t w i n _ a T o l R h o ( i )   < =   0 . 0 _ p R e a l )                                               c a l l   I O _ e r r o r ( 2 3 3 ) 
 
       ! *   D e t e r m i n e   t o t a l   n u m b e r   o f   a c t i v e   s l i p   o r   t w i n   s y s t e m s 
       c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( : , i )   =   m i n ( l a t t i c e _ N s l i p S y s t e m ( : , m y S t r u c t u r e ) , c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( : , i ) ) 
       c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ( : , i )   =   m i n ( l a t t i c e _ N t w i n S y s t e m ( : , m y S t r u c t u r e ) , c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ( : , i ) ) 
       c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( i )   =   s u m ( c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( : , i ) ) 
       c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( i )   =   s u m ( c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ( : , i ) ) 
 
 e n d d o 
 
 ! *   A l l o c a t i o n   o f   v a r i a b l e s   w h o s e   s i z e   d e p e n d s   o n   t h e   t o t a l   n u m b e r   o f   a c t i v e   s l i p   s y s t e m s 
 m a x T o t a l N s l i p   =   m a x v a l ( c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ) 
 m a x T o t a l N t w i n   =   m a x v a l ( c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ) 
 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( m a x T o t a l N s l i p ,   m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r T w i n S y s t e m ( m a x T o t a l N t w i n ,   m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p S y s t e m ( m a x T o t a l N s l i p ,   m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p S y s t e m ( m a x T o t a l N s l i p ,   m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n S y s t e m ( m a x T o t a l N t w i n ,   m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ t w i n s i z e P e r T w i n S y s t e m ( m a x T o t a l N t w i n ,   m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C L a m b d a S l i p P e r S l i p S y s t e m ( m a x T o t a l N s l i p ,   m a x N i n s t a n c e ) ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m           =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r T w i n S y s t e m           =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p S y s t e m               =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p S y s t e m                     =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n S y s t e m               =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ t w i n s i z e P e r T w i n S y s t e m         =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C L a m b d a S l i p P e r S l i p S y s t e m   =   0 . 0 _ p R e a l 
 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x S l i p S l i p ( m a x T o t a l N s l i p , m a x T o t a l N s l i p , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x S l i p T w i n ( m a x T o t a l N s l i p , m a x T o t a l N t w i n , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x T w i n S l i p ( m a x T o t a l N t w i n , m a x T o t a l N s l i p , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x T w i n T w i n ( m a x T o t a l N t w i n , m a x T o t a l N t w i n , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ f o r e s t P r o j e c t i o n E d g e ( m a x T o t a l N s l i p , m a x T o t a l N s l i p , m a x N i n s t a n c e ) ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x S l i p S l i p   =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x S l i p T w i n   =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x T w i n S l i p   =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x T w i n T w i n   =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ f o r e s t P r o j e c t i o n E d g e             =   0 . 0 _ p R e a l 
 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C t w i n _ 6 6 ( 6 , 6 , m a x T o t a l N t w i n , m a x N i n s t a n c e ) ) 
 a l l o c a t e ( c o n s t i t u t i v e _ d i s l o t w i n _ C t w i n _ 3 3 3 3 ( 3 , 3 , 3 , 3 , m a x T o t a l N t w i n , m a x N i n s t a n c e ) ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ C t w i n _ 6 6   =   0 . 0 _ p R e a l 
 c o n s t i t u t i v e _ d i s l o t w i n _ C t w i n _ 3 3 3 3   =   0 . 0 _ p R e a l 
 
 d o   i   =   1 , m a x N i n s t a n c e 
       m y S t r u c t u r e   =   c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e ( i ) 
 
       ! *   I n v e r s e   l o o k u p   o f   m y   s l i p   s y s t e m   f a m i l y 
       l   =   0 _ p I n t 
       d o   f   =   1 , l a t t i c e _ m a x N s l i p F a m i l y 
             d o   k   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( f , i ) 
                   l   =   l   +   1 
                   c o n s t i t u t i v e _ d i s l o t w i n _ s l i p F a m i l y ( l , i )   =   f 
                   c o n s t i t u t i v e _ d i s l o t w i n _ s l i p S y s t e m L a t t i c e ( l , i )   =   s u m ( l a t t i c e _ N s l i p S y s t e m ( 1 : f - 1 , m y S t r u c t u r e ) )   +   k 
       e n d d o ;   e n d d o 
 
       ! *   I n v e r s e   l o o k u p   o f   m y   t w i n   s y s t e m   f a m i l y 
       l   =   0 _ p I n t 
       d o   f   =   1 , l a t t i c e _ m a x N t w i n F a m i l y 
             d o   k   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ( f , i ) 
                   l   =   l   +   1 
                   c o n s t i t u t i v e _ d i s l o t w i n _ t w i n F a m i l y ( l , i )   =   f 
                   c o n s t i t u t i v e _ d i s l o t w i n _ t w i n S y s t e m L a t t i c e ( l , i )   =   s u m ( l a t t i c e _ N t w i n S y s t e m ( 1 : f - 1 , m y S t r u c t u r e ) )   +   k 
       e n d d o ;   e n d d o 
 
       ! *   D e t e r m i n e   s i z e   o f   s t a t e   a r r a y 
       n s   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( i ) 
       n t   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( i ) 
       c o n s t i t u t i v e _ d i s l o t w i n _ s i z e D o t S t a t e ( i )   =   & 
       s i z e ( c o n s t i t u t i v e _ d i s l o t w i n _ l i s t B a s i c S l i p S t a t e s ) * n s + s i z e ( c o n s t i t u t i v e _ d i s l o t w i n _ l i s t B a s i c T w i n S t a t e s ) * n t 
       c o n s t i t u t i v e _ d i s l o t w i n _ s i z e S t a t e ( i )   =   & 
       c o n s t i t u t i v e _ d i s l o t w i n _ s i z e D o t S t a t e ( i ) +   & 
       s i z e ( c o n s t i t u t i v e _ d i s l o t w i n _ l i s t D e p e n d e n t S l i p S t a t e s ) * n s + s i z e ( c o n s t i t u t i v e _ d i s l o t w i n _ l i s t D e p e n d e n t T w i n S t a t e s ) * n t 
 
       ! *   D e t e r m i n e   s i z e   o f   p o s t R e s u l t s   a r r a y 
       d o   o   =   1 , m a x v a l ( p h a s e _ N o u t p u t ) 
             s e l e c t   c a s e ( c o n s t i t u t i v e _ d i s l o t w i n _ o u t p u t ( o , i ) ) 
                 c a s e ( ' e d g e _ d e n s i t y ' ,   & 
                           ' d i p o l e _ d e n s i t y ' ,   & 
                           ' s h e a r _ r a t e _ s l i p ' ,   & 
                           ' m f p _ s l i p ' ,   & 
                           ' r e s o l v e d _ s t r e s s _ s l i p ' ,   & 
                           ' t h r e s h o l d _ s t r e s s _ s l i p ' ,   & 
                           ' e d g e _ d i p o l e _ d i s t a n c e ' ,   & 
                           ' s t r e s s _ e x p o n e n t '   & 
                           ) 
                       m y S i z e   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( i ) 
                 c a s e ( ' t w i n _ f r a c t i o n ' ,   & 
                           ' s h e a r _ r a t e _ t w i n ' ,   & 
                           ' m f p _ t w i n ' ,   & 
                           ' r e s o l v e d _ s t r e s s _ t w i n ' ,   & 
                           ' t h r e s h o l d _ s t r e s s _ t w i n '   & 
                           ) 
                       m y S i z e   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( i ) 
                 c a s e   d e f a u l t 
                       m y S i z e   =   0 _ p I n t 
             e n d   s e l e c t 
 
               i f   ( m y S i z e   >   0 _ p I n t )   t h e n     !   a n y   m e a n i n g f u l   o u t p u t   f o u n d 
                     c o n s t i t u t i v e _ d i s l o t w i n _ s i z e P o s t R e s u l t ( o , i )   =   m y S i z e 
                     c o n s t i t u t i v e _ d i s l o t w i n _ s i z e P o s t R e s u l t s ( i )     =   c o n s t i t u t i v e _ d i s l o t w i n _ s i z e P o s t R e s u l t s ( i )   +   m y S i z e 
               e n d i f 
       e n d d o 
 
       ! *   E l a s t i c i t y   m a t r i x   a n d   s h e a r   m o d u l u s   a c c o r d i n g   t o   m a t e r i a l . c o n f i g 
       s e l e c t   c a s e   ( m y S t r u c t u r e ) 
       c a s e ( 1 : 2 )   !   c u b i c ( s ) 
           f o r a l l ( k = 1 : 3 ) 
               f o r a l l ( j = 1 : 3 )   & 
                   c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( k , j , i )           =   c o n s t i t u t i v e _ d i s l o t w i n _ C 1 2 ( i ) 
                   c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( k , k , i )           =   c o n s t i t u t i v e _ d i s l o t w i n _ C 1 1 ( i ) 
                   c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( k + 3 , k + 3 , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C 4 4 ( i ) 
           e n d   f o r a l l 
       c a s e ( 3 : )       !   a l l   h e x 
           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 1 , 1 , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C 1 1 ( i ) 
           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 2 , 2 , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C 1 1 ( i ) 
           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 3 , 3 , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C 3 3 ( i ) 
           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 1 , 2 , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C 1 2 ( i ) 
           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 2 , 1 , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C 1 2 ( i ) 
           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 1 , 3 , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C 1 3 ( i ) 
           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 3 , 1 , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C 1 3 ( i ) 
           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 2 , 3 , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C 1 3 ( i ) 
           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 3 , 2 , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C 1 3 ( i ) 
           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 4 , 4 , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C 4 4 ( i ) 
           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 5 , 5 , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C 4 4 ( i ) 
           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( 6 , 6 , i )   =   0 . 5 _ p R e a l * ( c o n s t i t u t i v e _ d i s l o t w i n _ C 1 1 ( i ) - c o n s t i t u t i v e _ d i s l o t w i n _ C 1 2 ( i ) ) 
       e n d   s e l e c t 
       c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( : , : , i )   =   m a t h _ M a n d e l 3 3 3 3 t o 6 6 ( m a t h _ V o i g t 6 6 t o 3 3 3 3 ( c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( : , : , i ) ) ) 
       c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 3 3 3 3 ( : , : , : , : , i )   =   m a t h _ V o i g t 6 6 t o 3 3 3 3 ( c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( : , : , i ) ) 
       c o n s t i t u t i v e _ d i s l o t w i n _ G m o d ( i )   =   & 
       0 . 2 _ p R e a l * ( c o n s t i t u t i v e _ d i s l o t w i n _ C 1 1 ( i ) - c o n s t i t u t i v e _ d i s l o t w i n _ C 1 2 ( i ) ) + 0 . 3 _ p R e a l * c o n s t i t u t i v e _ d i s l o t w i n _ C 4 4 ( i ) 
 
       ! *   C o n s t r u c t i o n   o f   t h e   t w i n   e l a s t i c i t y   m a t r i c e s 
       d o   j = 1 , l a t t i c e _ m a x N t w i n F a m i l y 
             d o   k = 1 , c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ( j , i ) 
                   d o   l = 1 , 3   ;   d o   m = 1 , 3   ;   d o   n = 1 , 3   ;   d o   o = 1 , 3   ;   d o   p = 1 , 3   ;   d o   q = 1 , 3   ;   d o   r = 1 , 3   ;   d o   s = 1 , 3 
                       c o n s t i t u t i v e _ d i s l o t w i n _ C t w i n _ 3 3 3 3 ( l , m , n , o , s u m ( c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( 1 : j - 1 , i ) ) + k , i )   =   & 
                           c o n s t i t u t i v e _ d i s l o t w i n _ C t w i n _ 3 3 3 3 ( l , m , n , o , s u m ( c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( 1 : j - 1 , i ) ) + k , i )   +   & 
                           c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 3 3 3 3 ( p , q , r , s , i ) * & 
                           l a t t i c e _ Q t w i n ( l , p , s u m ( l a t t i c e _ N s l i p S y s t e m ( 1 : j - 1 , m y S t r u c t u r e ) ) + k , m y S t r u c t u r e ) *   & 
                           l a t t i c e _ Q t w i n ( m , q , s u m ( l a t t i c e _ N s l i p S y s t e m ( 1 : j - 1 , m y S t r u c t u r e ) ) + k , m y S t r u c t u r e ) *   & 
                           l a t t i c e _ Q t w i n ( n , r , s u m ( l a t t i c e _ N s l i p S y s t e m ( 1 : j - 1 , m y S t r u c t u r e ) ) + k , m y S t r u c t u r e ) *   & 
                           l a t t i c e _ Q t w i n ( o , s , s u m ( l a t t i c e _ N s l i p S y s t e m ( 1 : j - 1 , m y S t r u c t u r e ) ) + k , m y S t r u c t u r e ) 
                       e n d d o   ;   e n d d o   ;   e n d d o   ;   e n d d o   ;   e n d d o   ;   e n d d o   ;   e n d d o   ;   e n d d o 
                   c o n s t i t u t i v e _ d i s l o t w i n _ C t w i n _ 6 6 ( : , : , k , i )   =   m a t h _ M a n d e l 3 3 3 3 t o 6 6 ( c o n s t i t u t i v e _ d i s l o t w i n _ C t w i n _ 3 3 3 3 ( : , : , : , : , k , i ) ) 
                 e n d d o 
       e n d d o 
 
       ! *   B u r g e r s   v e c t o r ,   d i s l o c a t i o n   v e l o c i t y   p r e f a c t o r ,   m e a n   f r e e   p a t h   p r e f a c t o r   a n d   m i n i m u m   d i p o l e   d i s t a n c e   f o r   e a c h   s l i p   s y s t e m 
       d o   s   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( i ) 
             f   =   c o n s t i t u t i v e _ d i s l o t w i n _ s l i p F a m i l y ( s , i ) 
             c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( s , i )           =   c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p F a m i l y ( f , i ) 
             c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p S y s t e m ( s , i )               =   c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p F a m i l y ( f , i ) 
             c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p S y s t e m ( s , i )                     =   c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p F a m i l y ( f , i ) 
             c o n s t i t u t i v e _ d i s l o t w i n _ C L a m b d a S l i p P e r S l i p S y s t e m ( s , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ C L a m b d a S l i p P e r S l i p F a m i l y ( f , i ) 
       e n d d o 
 
       ! *   B u r g e r s   v e c t o r ,   n u c l e a t i o n   r a t e   p r e f a c t o r   a n d   t w i n   s i z e   f o r   e a c h   t w i n   s y s t e m 
       d o   s   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( i ) 
             f   =   c o n s t i t u t i v e _ d i s l o t w i n _ t w i n F a m i l y ( s , i ) 
             c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r T w i n S y s t e m ( s , i )     =   c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r T w i n F a m i l y ( f , i ) 
             c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n S y s t e m ( s , i )         =   c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n F a m i l y ( f , i ) 
             c o n s t i t u t i v e _ d i s l o t w i n _ t w i n s i z e P e r T w i n S y s t e m ( s , i )   =   c o n s t i t u t i v e _ d i s l o t w i n _ t w i n s i z e P e r T w i n F a m i l y ( f , i ) 
       e n d d o 
 
       ! *   C o n s t r u c t i o n   o f   i n t e r a c t i o n   m a t r i c e s 
       d o   s 1   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( i ) 
             d o   s 2   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( i ) 
                   c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x S l i p S l i p ( s 1 , s 2 , i )   =   & 
                   c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n S l i p S l i p ( l a t t i c e _ i n t e r a c t i o n S l i p S l i p ( c o n s t i t u t i v e _ d i s l o t w i n _ s l i p S y s t e m L a t t i c e ( s 1 , i ) ,   & 
                                                                                                                                                                 c o n s t i t u t i v e _ d i s l o t w i n _ s l i p S y s t e m L a t t i c e ( s 2 , i ) ,   & 
                                                                                                                                                                 m y S t r u c t u r e ) , i ) 
       e n d d o ;   e n d d o 
 
       d o   s 1   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( i ) 
             d o   t 2   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( i ) 
                   c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x S l i p T w i n ( s 1 , t 2 , i )   =   & 
                   c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n S l i p T w i n ( l a t t i c e _ i n t e r a c t i o n S l i p T w i n ( c o n s t i t u t i v e _ d i s l o t w i n _ s l i p S y s t e m L a t t i c e ( s 1 , i ) ,   & 
                                                                                                                                                                 c o n s t i t u t i v e _ d i s l o t w i n _ t w i n S y s t e m L a t t i c e ( t 2 , i ) ,   & 
                                                                                                                                                                 m y S t r u c t u r e ) , i ) 
       e n d d o ;   e n d d o 
 
       d o   t 1   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( i ) 
             d o   s 2   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( i ) 
                   c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x T w i n S l i p ( t 1 , s 2 , i )   =   & 
                   c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n T w i n S l i p ( l a t t i c e _ i n t e r a c t i o n T w i n S l i p ( c o n s t i t u t i v e _ d i s l o t w i n _ t w i n S y s t e m L a t t i c e ( t 1 , i ) ,   & 
                                                                                                                                                                 c o n s t i t u t i v e _ d i s l o t w i n _ s l i p S y s t e m L a t t i c e ( s 2 , i ) ,   & 
                                                                                                                                                                 m y S t r u c t u r e ) , i ) 
       e n d d o ;   e n d d o 
 
       d o   t 1   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( i ) 
             d o   t 2   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( i ) 
                   c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x T w i n T w i n ( t 1 , t 2 , i )   =   & 
                   c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n T w i n T w i n ( l a t t i c e _ i n t e r a c t i o n T w i n T w i n ( c o n s t i t u t i v e _ d i s l o t w i n _ t w i n S y s t e m L a t t i c e ( t 1 , i ) ,   & 
                                                                                                                                                                 c o n s t i t u t i v e _ d i s l o t w i n _ t w i n S y s t e m L a t t i c e ( t 2 , i ) ,   & 
                                                                                                                                                                 m y S t r u c t u r e ) , i ) 
       e n d d o ;   e n d d o 
 
       ! *   C a l c u l a t i o n   o f   f o r e s t   p r o j e c t i o n s   f o r   e d g e   d i s l o c a t i o n s 
       d o   s 1   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( i ) 
             d o   s 2   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( i ) 
                   c o n s t i t u t i v e _ d i s l o t w i n _ f o r e s t P r o j e c t i o n E d g e ( s 1 , s 2 , i )   =   & 
                   a b s ( m a t h _ m u l 3 x 3 ( l a t t i c e _ s n ( : , c o n s t i t u t i v e _ d i s l o t w i n _ s l i p S y s t e m L a t t i c e ( s 1 , i ) , m y S t r u c t u r e ) ,   & 
                                                   l a t t i c e _ s t ( : , c o n s t i t u t i v e _ d i s l o t w i n _ s l i p S y s t e m L a t t i c e ( s 2 , i ) , m y S t r u c t u r e ) ) ) 
       e n d d o ;   e n d d o 
 
 e n d d o 
 
 r e t u r n 
 e n d   s u b r o u t i n e 
 
 
 f u n c t i o n   c o n s t i t u t i v e _ d i s l o t w i n _ s t a t e I n i t ( m y I n s t a n c e ) 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 ! *   i n i t i a l   m i c r o s t r u c t u r a l   s t a t e                                                                           * 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 u s e   p r e c ,         o n l y :   p R e a l , p I n t 
 u s e   m a t h ,         o n l y :   p i 
 u s e   l a t t i c e ,   o n l y :   l a t t i c e _ m a x N s l i p F a m i l y , l a t t i c e _ m a x N t w i n F a m i l y 
 i m p l i c i t   n o n e 
 
 ! *   I n p u t - O u t p u t   v a r i a b l e s 
 i n t e g e r ( p I n t )   : :   m y I n s t a n c e 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( c o n s t i t u t i v e _ d i s l o t w i n _ s i z e S t a t e ( m y I n s t a n c e ) )     : :   c o n s t i t u t i v e _ d i s l o t w i n _ s t a t e I n i t 
 ! *   L o c a l   v a r i a b l e s 
 i n t e g e r ( p I n t )   s 0 , s 1 , s , t , f , n s , n t 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( m y I n s t a n c e ) )   : :   r h o E d g e 0 ,   & 
                                                                                                                                                   r h o E d g e D i p 0 ,   & 
                                                                                                                                                   i n v L a m b d a S l i p 0 ,   & 
                                                                                                                                                   M e a n F r e e P a t h S l i p 0 ,   & 
                                                                                                                                                   t a u S l i p T h r e s h o l d 0 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( m y I n s t a n c e ) )   : :   M e a n F r e e P a t h T w i n 0 , T w i n V o l u m e 0 
 
 n s   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( m y I n s t a n c e ) 
 n t   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( m y I n s t a n c e ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ s t a t e I n i t   =   0 . 0 _ p R e a l 
 
 ! *   I n i t i a l i z e   b a s i c   s l i p   s t a t e   v a r i a b l e s 
 s 1   =   0 _ p I n t 
 d o   f   =   1 , l a t t i c e _ m a x N s l i p F a m i l y 
       s 0   =   s 1   +   1 _ p I n t 
       s 1   =   s 0   +   c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( f , m y I n s t a n c e )   -   1 _ p I n t 
       d o   s   =   s 0 , s 1 
             r h o E d g e 0 ( s )         =   c o n s t i t u t i v e _ d i s l o t w i n _ r h o E d g e 0 ( f , m y I n s t a n c e ) 
             r h o E d g e D i p 0 ( s )   =   c o n s t i t u t i v e _ d i s l o t w i n _ r h o E d g e D i p 0 ( f , m y I n s t a n c e ) 
       e n d d o 
 e n d d o 
 c o n s t i t u t i v e _ d i s l o t w i n _ s t a t e I n i t ( 1 : n s )             =   r h o E d g e 0 
 c o n s t i t u t i v e _ d i s l o t w i n _ s t a t e I n i t ( n s + 1 : 2 * n s )   =   r h o E d g e D i p 0 
 
 ! *   I n i t i a l i z e   d e p e n d e n t   s l i p   m i c r o s t r u c t u r a l   v a r i a b l e s 
 f o r a l l   ( s   =   1 : n s )   & 
 i n v L a m b d a S l i p 0 ( s )   =   s q r t ( d o t _ p r o d u c t ( ( r h o E d g e 0 + r h o E d g e D i p 0 ) , c o n s t i t u t i v e _ d i s l o t w i n _ f o r e s t P r o j e c t i o n E d g e ( 1 : n s , s , m y I n s t a n c e ) ) ) /   & 
 c o n s t i t u t i v e _ d i s l o t w i n _ C L a m b d a S l i p P e r S l i p S y s t e m ( s , m y I n s t a n c e ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ s t a t e I n i t ( 2 * n s + n t + 1 : 3 * n s + n t )   =   i n v L a m b d a S l i p 0 
 
 f o r a l l   ( s   =   1 : n s )   & 
 M e a n F r e e P a t h S l i p 0 ( s )   =   & 
 c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e ( m y I n s t a n c e ) / ( 1 . 0 _ p R e a l + i n v L a m b d a S l i p 0 ( s ) * c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e ( m y I n s t a n c e ) ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ s t a t e I n i t ( 4 * n s + 2 * n t + 1 : 5 * n s + 2 * n t )   =   M e a n F r e e P a t h S l i p 0 
 
 f o r a l l   ( s   =   1 : n s )   & 
 t a u S l i p T h r e s h o l d 0 ( s )   =   c o n s t i t u t i v e _ d i s l o t w i n _ S o l i d S o l u t i o n S t r e n g t h ( m y I n s t a n c e ) +   & 
 c o n s t i t u t i v e _ d i s l o t w i n _ G m o d ( m y I n s t a n c e ) * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( s , m y I n s t a n c e ) *   & 
 s q r t ( d o t _ p r o d u c t ( ( r h o E d g e 0 + r h o E d g e D i p 0 ) , c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x S l i p S l i p ( 1 : n s , s , m y I n s t a n c e ) ) ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ s t a t e I n i t ( 5 * n s + 3 * n t + 1 : 6 * n s + 3 * n t )   =   t a u S l i p T h r e s h o l d 0 
 
 ! *   I n i t i a l i z e   d e p e n d e n t   t w i n   m i c r o s t r u c t u r a l   v a r i a b l e s 
 f o r a l l   ( t   =   1 : n t )   & 
 M e a n F r e e P a t h T w i n 0 ( t )   =   c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e ( m y I n s t a n c e ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ s t a t e I n i t ( 5 * n s + 2 * n t + 1 : 5 * n s + 3 * n t )   =   M e a n F r e e P a t h T w i n 0 
 
 f o r a l l   ( t   =   1 : n t )   & 
 T w i n V o l u m e 0 ( t )   =   & 
 ( p i / 6 . 0 _ p R e a l ) * c o n s t i t u t i v e _ d i s l o t w i n _ t w i n s i z e P e r T w i n S y s t e m ( t , m y I n s t a n c e ) * M e a n F r e e P a t h T w i n 0 ( t ) * * ( 2 . 0 _ p R e a l ) 
 c o n s t i t u t i v e _ d i s l o t w i n _ s t a t e I n i t ( 6 * n s + 4 * n t + 1 : 6 * n s + 5 * n t )   =   T w i n V o l u m e 0 
 
 ! w r i t e ( 6 , * )   ' # S T A T E I N I T # ' 
 ! w r i t e ( 6 , * ) 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' R h o E d g e ' , r h o E d g e 0 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' R h o E d g e d i p ' , r h o E d g e D i p 0 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' i n v L a m b d a S l i p ' , i n v L a m b d a S l i p 0 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' M e a n F r e e P a t h S l i p ' , M e a n F r e e P a t h S l i p 0 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' t a u S l i p T h r e s h o l d ' ,   t a u S l i p T h r e s h o l d 0 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' M e a n F r e e P a t h T w i n ' ,   M e a n F r e e P a t h T w i n 0 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' T w i n V o l u m e ' ,   T w i n V o l u m e 0 
 
 r e t u r n 
 e n d   f u n c t i o n 
 
 
 p u r e   f u n c t i o n   c o n s t i t u t i v e _ d i s l o t w i n _ a T o l S t a t e ( m y I n s t a n c e ) 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 ! *   a b s o l u t e   s t a t e   t o l e r a n c e                                                                                     * 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 u s e   p r e c ,           o n l y :   p R e a l ,   p I n t 
 i m p l i c i t   n o n e 
 
 ! *   I n p u t - O u t p u t   v a r i a b l e s 
 i n t e g e r ( p I n t ) ,   i n t e n t ( i n )   : :   m y I n s t a n c e 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( c o n s t i t u t i v e _ d i s l o t w i n _ s i z e S t a t e ( m y I n s t a n c e ) )   : :   c o n s t i t u t i v e _ d i s l o t w i n _ a T o l S t a t e 
 
 c o n s t i t u t i v e _ d i s l o t w i n _ a T o l S t a t e   =   c o n s t i t u t i v e _ d i s l o t w i n _ a T o l R h o ( m y I n s t a n c e ) 
 
 r e t u r n 
 e n d f u n c t i o n 
 
 
 p u r e   f u n c t i o n   c o n s t i t u t i v e _ d i s l o t w i n _ h o m o g e n i z e d C ( s t a t e , g , i p , e l ) 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 ! *   c a l c u l a t e s   h o m o g e n i z e d   e l a c t i c i t y   m a t r i x                                                     * 
 ! *     -   s t a t e                       :   m i c r o s t r u c t u r e   q u a n t i t i e s                                         * 
 ! *     -   g                               :   c o m p o n e n t - I D   o f   c u r r e n t   i n t e g r a t i o n   p o i n t         * 
 ! *     -   i p                             :   c u r r e n t   i n t e g r a t i o n   p o i n t                                         * 
 ! *     -   e l                             :   c u r r e n t   e l e m e n t                                                             * 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 u s e   p r e c ,           o n l y :   p R e a l , p I n t , p _ v e c 
 u s e   m e s h ,           o n l y :   m e s h _ N c p E l e m s , m e s h _ m a x N i p s 
 u s e   m a t e r i a l ,   o n l y :   h o m o g e n i z a t i o n _ m a x N g r a i n s , m a t e r i a l _ p h a s e , p h a s e _ c o n s t i t u t i o n I n s t a n c e 
 i m p l i c i t   n o n e 
 
 ! *   I n p u t - O u t p u t   v a r i a b l e s 
 i n t e g e r ( p I n t ) ,   i n t e n t ( i n )   : :   g , i p , e l 
 t y p e ( p _ v e c ) ,   d i m e n s i o n ( h o m o g e n i z a t i o n _ m a x N g r a i n s , m e s h _ m a x N i p s , m e s h _ N c p E l e m s ) ,   i n t e n t ( i n )   : :   s t a t e 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( 6 , 6 )   : :   c o n s t i t u t i v e _ d i s l o t w i n _ h o m o g e n i z e d C 
 ! *   L o c a l   v a r i a b l e s 
 i n t e g e r ( p I n t )   m y I n s t a n c e , n s , n t , i 
 r e a l ( p R e a l )   s u m f 
 
 ! *   S h o r t e n e d   n o t a t i o n 
 m y I n s t a n c e   =   p h a s e _ c o n s t i t u t i o n I n s t a n c e ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) 
 n s   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( m y I n s t a n c e ) 
 n t   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( m y I n s t a n c e ) 
 
 ! *   T o t a l   t w i n   v o l u m e   f r a c t i o n 
 s u m f   =   s u m ( s t a t e ( g , i p , e l ) % p ( ( 2 * n s + 1 ) : ( 2 * n s + n t ) ) )   !   s a f e   f o r   n t   = =   0 
 
 ! *   H o m o g e n i z e d   e l a s t i c i t y   m a t r i x 
 c o n s t i t u t i v e _ d i s l o t w i n _ h o m o g e n i z e d C   =   ( 1 . 0 _ p R e a l - s u m f ) * c o n s t i t u t i v e _ d i s l o t w i n _ C s l i p _ 6 6 ( : , : , m y I n s t a n c e ) 
 d o   i = 1 , n t 
       c o n s t i t u t i v e _ d i s l o t w i n _ h o m o g e n i z e d C   =   & 
       c o n s t i t u t i v e _ d i s l o t w i n _ h o m o g e n i z e d C   +   s t a t e ( g , i p , e l ) % p ( 2 * n s + i ) * c o n s t i t u t i v e _ d i s l o t w i n _ C t w i n _ 6 6 ( : , : , i , m y I n s t a n c e ) 
 e n d d o 
 
 r e t u r n 
 e n d   f u n c t i o n 
 
 
 s u b r o u t i n e   c o n s t i t u t i v e _ d i s l o t w i n _ m i c r o s t r u c t u r e ( T e m p e r a t u r e , s t a t e , g , i p , e l ) 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 ! *   c a l c u l a t e s   q u a n t i t i e s   c h a r a c t e r i z i n g   t h e   m i c r o s t r u c t u r e                       * 
 ! *     -   T e m p e r a t u r e           :   t e m p e r a t u r e                                                                     * 
 ! *     -   s t a t e                       :   m i c r o s t r u c t u r e   q u a n t i t i e s                                         * 
 ! *     -   i p c                           :   c o m p o n e n t - I D   o f   c u r r e n t   i n t e g r a t i o n   p o i n t         * 
 ! *     -   i p                             :   c u r r e n t   i n t e g r a t i o n   p o i n t                                         * 
 ! *     -   e l                             :   c u r r e n t   e l e m e n t                                                             * 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 u s e   p r e c ,           o n l y :   p R e a l , p I n t , p _ v e c 
 u s e   m a t h ,           o n l y :   p i 
 u s e   m e s h ,           o n l y :   m e s h _ N c p E l e m s , m e s h _ m a x N i p s 
 u s e   m a t e r i a l ,   o n l y :   h o m o g e n i z a t i o n _ m a x N g r a i n s , m a t e r i a l _ p h a s e , p h a s e _ c o n s t i t u t i o n I n s t a n c e 
 u s e   l a t t i c e ,     o n l y :   l a t t i c e _ i n t e r a c t i o n S l i p T w i n , l a t t i c e _ i n t e r a c t i o n T w i n T w i n 
 ! u s e   d e b u g ,         o n l y :   d e b u g g e r 
 i m p l i c i t   n o n e 
 
 ! *   I n p u t - O u t p u t   v a r i a b l e s 
 i n t e g e r ( p I n t ) ,   i n t e n t ( i n )   : :   g , i p , e l 
 r e a l ( p R e a l ) ,   i n t e n t ( i n )   : :   T e m p e r a t u r e 
 t y p e ( p _ v e c ) ,   d i m e n s i o n ( h o m o g e n i z a t i o n _ m a x N g r a i n s , m e s h _ m a x N i p s , m e s h _ N c p E l e m s ) ,   i n t e n t ( i n o u t )   : :   s t a t e 
 ! *   L o c a l   v a r i a b l e s 
 i n t e g e r ( p I n t )   m y I n s t a n c e , m y S t r u c t u r e , n s , n t , s , t 
 r e a l ( p R e a l )   s u m f , s f e 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( p h a s e _ c o n s t i t u t i o n I n s t a n c e ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) ) )   : :   f O v e r S t a c k s i z e 
 
 ! *   S h o r t e n e d   n o t a t i o n 
 m y I n s t a n c e   =   p h a s e _ c o n s t i t u t i o n I n s t a n c e ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) 
 m y S t r u c t u r e   =   c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e ( m y I n s t a n c e ) 
 n s   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( m y I n s t a n c e ) 
 n t   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( m y I n s t a n c e ) 
 ! *   S t a t e :   1                       :     n s                   r h o _ e d g e 
 ! *   S t a t e :   n s + 1                 :     2 * n s               r h o _ d i p o l e 
 ! *   S t a t e :   2 * n s + 1             :     2 * n s + n t         f 
 ! *   S t a t e :   2 * n s + n t + 1       :     3 * n s + n t         1 / l a m b d a _ s l i p 
 ! *   S t a t e :   3 * n s + n t + 1       :     4 * n s + n t         1 / l a m b d a _ s l i p t w i n 
 ! *   S t a t e :   4 * n s + n t + 1       :     4 * n s + 2 * n t     1 / l a m b d a _ t w i n 
 ! *   S t a t e :   4 * n s + 2 * n t + 1   :     5 * n s + 2 * n t     m f p _ s l i p 
 ! *   S t a t e :   5 * n s + 2 * n t + 1   :     5 * n s + 3 * n t     m f p _ t w i n 
 ! *   S t a t e :   5 * n s + 3 * n t + 1   :     6 * n s + 3 * n t     t h r e s h o l d _ s t r e s s _ s l i p 
 ! *   S t a t e :   6 * n s + 3 * n t + 1   :     6 * n s + 4 * n t     t h r e s h o l d _ s t r e s s _ t w i n 
 ! *   S t a t e :   6 * n s + 4 * n t + 1   :     6 * n s + 5 * n t     t w i n   v o l u m e 
 
 ! *   T o t a l   t w i n   v o l u m e   f r a c t i o n 
 s u m f   =   s u m ( s t a t e ( g , i p , e l ) % p ( ( 2 * n s + 1 ) : ( 2 * n s + n t ) ) )   !   s a f e   f o r   n t   = =   0 
 
 ! *   S t a c k i n g   f a u l t   e n e r g y 
 s f e   =   0 . 0 0 0 2 _ p R e a l * T e m p e r a t u r e - 0 . 0 3 9 6 _ p R e a l 
 
 ! *   r e s c a l e d   t w i n   v o l u m e   f r a c t i o n   f o r   t o p o l o g y 
 f o r a l l   ( t   =   1 : n t )   & 
     f O v e r S t a c k s i z e ( t )   =   & 
         s t a t e ( g , i p , e l ) % p ( 2 * n s + t ) / c o n s t i t u t i v e _ d i s l o t w i n _ t w i n s i z e P e r T w i n S y s t e m ( t , m y I n s t a n c e ) 
 
 ! *   1 / m e a n   f r e e   d i s t a n c e   b e t w e e n   2   f o r e s t   d i s l o c a t i o n s   s e e n   b y   a   m o v i n g   d i s l o c a t i o n 
 f o r a l l   ( s   =   1 : n s )   & 
     s t a t e ( g , i p , e l ) % p ( 2 * n s + n t + s )   =   & 
         s q r t ( d o t _ p r o d u c t ( ( s t a t e ( g , i p , e l ) % p ( 1 : n s ) + s t a t e ( g , i p , e l ) % p ( n s + 1 : 2 * n s ) ) , & 
                                           c o n s t i t u t i v e _ d i s l o t w i n _ f o r e s t P r o j e c t i o n E d g e ( 1 : n s , s , m y I n s t a n c e ) ) ) /   & 
         c o n s t i t u t i v e _ d i s l o t w i n _ C L a m b d a S l i p P e r S l i p S y s t e m ( s , m y I n s t a n c e ) 
 
 ! *   1 / m e a n   f r e e   d i s t a n c e   b e t w e e n   2   t w i n   s t a c k s   f r o m   d i f f e r e n t   s y s t e m s   s e e n   b y   a   m o v i n g   d i s l o c a t i o n 
 ! $ O M P   C R I T I C A L   ( e v i l m a t m u l ) 
 s t a t e ( g , i p , e l ) % p ( ( 3 * n s + n t + 1 ) : ( 4 * n s + n t ) )   =   0 . 0 _ p R e a l 
 i f   ( n t   >   0 _ p I n t )   & 
     s t a t e ( g , i p , e l ) % p ( ( 3 * n s + n t + 1 ) : ( 4 * n s + n t ) )   =   & 
         m a t m u l ( c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x S l i p T w i n ( 1 : n s , 1 : n t , m y I n s t a n c e ) , f O v e r S t a c k s i z e ( 1 : n t ) ) / ( 1 . 0 _ p R e a l - s u m f ) 
 ! $ O M P   E N D   C R I T I C A L   ( e v i l m a t m u l ) 
 
 ! *   1 / m e a n   f r e e   d i s t a n c e   b e t w e e n   2   t w i n   s t a c k s   f r o m   d i f f e r e n t   s y s t e m s   s e e n   b y   a   g r o w i n g   t w i n 
 ! $ O M P   C R I T I C A L   ( e v i l m a t m u l ) 
 i f   ( n t   >   0 _ p I n t )   & 
     s t a t e ( g , i p , e l ) % p ( ( 4 * n s + n t + 1 ) : ( 4 * n s + 2 * n t ) )   =   & 
         m a t m u l ( c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x T w i n T w i n ( 1 : n t , 1 : n t , m y I n s t a n c e ) , f O v e r S t a c k s i z e ( 1 : n t ) ) / ( 1 . 0 _ p R e a l - s u m f ) 
 ! $ O M P   E N D   C R I T I C A L   ( e v i l m a t m u l ) 
 
 ! *   m e a n   f r e e   p a t h   b e t w e e n   2   o b s t a c l e s   s e e n   b y   a   m o v i n g   d i s l o c a t i o n 
 d o   s   =   1 , n s 
       i f   ( n t   >   0 _ p I n t )   t h e n 
             s t a t e ( g , i p , e l ) % p ( 4 * n s + 2 * n t + s )   =   & 
                 c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e ( m y I n s t a n c e ) / ( 1 . 0 _ p R e a l + c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e ( m y I n s t a n c e ) * & 
                 ( s t a t e ( g , i p , e l ) % p ( 2 * n s + n t + s ) + s t a t e ( g , i p , e l ) % p ( 3 * n s + n t + s ) ) ) 
       e l s e 
             s t a t e ( g , i p , e l ) % p ( 4 * n s + s )   =   & 
                 c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e ( m y I n s t a n c e ) / & 
                 ( 1 . 0 _ p R e a l + c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e ( m y I n s t a n c e ) * ( s t a t e ( g , i p , e l ) % p ( 2 * n s + s ) ) ) 
       e n d i f 
 e n d d o 
 
 ! *   m e a n   f r e e   p a t h   b e t w e e n   2   o b s t a c l e s   s e e n   b y   a   g r o w i n g   t w i n 
 f o r a l l   ( t   =   1 : n t )   & 
     s t a t e ( g , i p , e l ) % p ( 5 * n s + 2 * n t + t )   =   & 
         ( c o n s t i t u t i v e _ d i s l o t w i n _ C m f p t w i n ( m y I n s t a n c e ) * c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e ( m y I n s t a n c e ) ) / & 
         ( 1 . 0 _ p R e a l + c o n s t i t u t i v e _ d i s l o t w i n _ G r a i n S i z e ( m y I n s t a n c e ) * s t a t e ( g , i p , e l ) % p ( 4 * n s + n t + t ) ) 
 
 ! *   t h r e s h o l d   s t r e s s   f o r   d i s l o c a t i o n   m o t i o n 
 f o r a l l   ( s   =   1 : n s )   & 
     s t a t e ( g , i p , e l ) % p ( 5 * n s + 3 * n t + s )   =   c o n s t i t u t i v e _ d i s l o t w i n _ S o l i d S o l u t i o n S t r e n g t h ( m y I n s t a n c e ) +   & 
         c o n s t i t u t i v e _ d i s l o t w i n _ G m o d ( m y I n s t a n c e ) * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( s , m y I n s t a n c e ) * & 
         s q r t ( d o t _ p r o d u c t ( ( s t a t e ( g , i p , e l ) % p ( 1 : n s ) + s t a t e ( g , i p , e l ) % p ( n s + 1 : 2 * n s ) ) , & 
                                           c o n s t i t u t i v e _ d i s l o t w i n _ i n t e r a c t i o n M a t r i x S l i p S l i p ( 1 : n s , s , m y I n s t a n c e ) ) ) 
 
 ! *   t h r e s h o l d   s t r e s s   f o r   g r o w i n g   t w i n 
 f o r a l l   ( t   =   1 : n t )   & 
     s t a t e ( g , i p , e l ) % p ( 6 * n s + 3 * n t + t )   =   & 
         c o n s t i t u t i v e _ d i s l o t w i n _ C t h r e s h o l d t w i n ( m y I n s t a n c e ) * & 
         ( s f e / ( 3 . 0 _ p R e a l * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r T w i n S y s t e m ( t , m y I n s t a n c e ) ) + & 
         3 . 0 _ p R e a l * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r T w i n S y s t e m ( t , m y I n s t a n c e ) * c o n s t i t u t i v e _ d i s l o t w i n _ G m o d ( m y I n s t a n c e ) / & 
         ( c o n s t i t u t i v e _ d i s l o t w i n _ L 0 ( m y I n s t a n c e ) * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( t , m y I n s t a n c e ) ) ) 
 
 ! *   f i n a l   t w i n   v o l u m e   a f t e r   g r o w t h 
 f o r a l l   ( t   =   1 : n t )   & 
     s t a t e ( g , i p , e l ) % p ( 6 * n s + 4 * n t + t )   =   & 
         ( p i / 6 . 0 _ p R e a l ) * c o n s t i t u t i v e _ d i s l o t w i n _ t w i n s i z e P e r T w i n S y s t e m ( t , m y I n s t a n c e ) * s t a t e ( g , i p , e l ) % p ( 5 * n s + 2 * n t + t ) * * ( 2 . 0 _ p R e a l ) 
 
 ! i f   ( ( i p = = 1 ) . a n d . ( e l = = 1 ) )   t h e n 
 !       w r i t e ( 6 , * )   ' # M I C R O S T R U C T U R E # ' 
 !   w r i t e ( 6 , * ) 
 !   w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 1 0 . 4 , x ) / ) ) ' )   ' r h o E d g e ' , s t a t e ( g , i p , e l ) % p ( 1 : n s ) / 1 e 9 
 !   w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 1 0 . 4 , x ) / ) ) ' )   ' r h o E d g e D i p ' , s t a t e ( g , i p , e l ) % p ( n s + 1 : 2 * n s ) / 1 e 9 
 !   w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 1 0 . 4 , x ) / ) ) ' )   ' F r a c t i o n ' , s t a t e ( g , i p , e l ) % p ( 2 * n s + 1 : 2 * n s + n t ) 
 ! e n d i f 
 
 
 r e t u r n 
 e n d   s u b r o u t i n e 
 
 
 s u b r o u t i n e   c o n s t i t u t i v e _ d i s l o t w i n _ L p A n d I t s T a n g e n t ( L p , d L p _ d T s t a r , T s t a r _ v , T e m p e r a t u r e , s t a t e , g , i p , e l ) 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 ! *   c a l c u l a t e s   p l a s t i c   v e l o c i t y   g r a d i e n t   a n d   i t s   t a n g e n t                             * 
 ! *   I N P U T :                                                                                                                         * 
 ! *     -   T e m p e r a t u r e           :   t e m p e r a t u r e                                                                     * 
 ! *     -   s t a t e                       :   m i c r o s t r u c t u r e   q u a n t i t i e s                                         * 
 ! *     -   T s t a r _ v                   :   2 n d   P i o l a   K i r c h h o f f   s t r e s s   t e n s o r   ( M a n d e l )       * 
 ! *     -   i p c                           :   c o m p o n e n t - I D   a t   c u r r e n t   i n t e g r a t i o n   p o i n t         * 
 ! *     -   i p                             :   c u r r e n t   i n t e g r a t i o n   p o i n t                                         * 
 ! *     -   e l                             :   c u r r e n t   e l e m e n t                                                             * 
 ! *   O U T P U T :                                                                                                                       * 
 ! *     -   L p                             :   p l a s t i c   v e l o c i t y   g r a d i e n t                                         * 
 ! *     -   d L p _ d T s t a r             :   d e r i v a t i v e   o f   L p   ( 4 t h - r a n k   t e n s o r )                       * 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 u s e   p r e c ,           o n l y :   p R e a l , p I n t , p _ v e c 
 u s e   m a t h ,           o n l y :   m a t h _ P l a i n 3 3 3 3 t o 9 9 
 u s e   m e s h ,           o n l y :   m e s h _ N c p E l e m s , m e s h _ m a x N i p s 
 u s e   m a t e r i a l ,   o n l y :   h o m o g e n i z a t i o n _ m a x N g r a i n s , m a t e r i a l _ p h a s e , p h a s e _ c o n s t i t u t i o n I n s t a n c e 
 u s e   l a t t i c e ,     o n l y :   l a t t i c e _ S s l i p , l a t t i c e _ S s l i p _ v , l a t t i c e _ S t w i n , l a t t i c e _ S t w i n _ v , l a t t i c e _ m a x N s l i p F a m i l y , l a t t i c e _ m a x N t w i n F a m i l y ,   & 
                                         l a t t i c e _ N s l i p S y s t e m , l a t t i c e _ N t w i n S y s t e m , l a t t i c e _ s h e a r T w i n 
 i m p l i c i t   n o n e 
 
 ! *   I n p u t - O u t p u t   v a r i a b l e s 
 i n t e g e r ( p I n t ) ,   i n t e n t ( i n )   : :   g , i p , e l 
 r e a l ( p R e a l ) ,   i n t e n t ( i n )   : :   T e m p e r a t u r e 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( 6 ) ,   i n t e n t ( i n )   : :   T s t a r _ v 
 t y p e ( p _ v e c ) ,   d i m e n s i o n ( h o m o g e n i z a t i o n _ m a x N g r a i n s , m e s h _ m a x N i p s , m e s h _ N c p E l e m s ) ,   i n t e n t ( i n o u t )   : :   s t a t e 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( 3 , 3 ) ,   i n t e n t ( o u t )   : :   L p 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( 9 , 9 ) ,   i n t e n t ( o u t )   : :   d L p _ d T s t a r 
 ! *   L o c a l   v a r i a b l e s 
 i n t e g e r ( p I n t )   m y I n s t a n c e , m y S t r u c t u r e , n s , n t , f , i , j , k , l , m , n , i n d e x _ m y F a m i l y 
 r e a l ( p R e a l )   s u m f , S t r e s s R a t i o _ p , S t r e s s R a t i o _ p m i n u s 1 , S t r e s s R a t i o _ r , B o l t z m a n n R a t i o , D o t G a m m a 0 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( 3 , 3 , 3 , 3 )   : :   d L p _ d T s t a r 3 3 3 3 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( p h a s e _ c o n s t i t u t i o n I n s t a n c e ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) ) )   : :   & 
       g d o t _ s l i p , d g d o t _ d t a u s l i p , t a u _ s l i p 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( p h a s e _ c o n s t i t u t i o n I n s t a n c e ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) ) )   : :   & 
       g d o t _ t w i n , d g d o t _ d t a u t w i n , t a u _ t w i n 
 
 ! *   S h o r t e n e d   n o t a t i o n 
 m y I n s t a n c e     =   p h a s e _ c o n s t i t u t i o n I n s t a n c e ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) 
 m y S t r u c t u r e   =   c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e ( m y I n s t a n c e ) 
 n s   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( m y I n s t a n c e ) 
 n t   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( m y I n s t a n c e ) 
 
 ! *   T o t a l   t w i n   v o l u m e   f r a c t i o n 
 s u m f   =   s u m ( s t a t e ( g , i p , e l ) % p ( ( 2 * n s + 1 ) : ( 2 * n s + n t ) ) )   !   s a f e   f o r   n t   = =   0 
 
 L p   =   0 . 0 _ p R e a l 
 d L p _ d T s t a r 3 3 3 3   =   0 . 0 _ p R e a l 
 d L p _ d T s t a r   =   0 . 0 _ p R e a l 
 
 ! *   D i s l o c a t i o n   g l i d e   p a r t 
 g d o t _ s l i p   =   0 . 0 _ p R e a l 
 d g d o t _ d t a u s l i p   =   0 . 0 _ p R e a l 
 j   =   0 _ p I n t 
 d o   f   =   1 , l a t t i c e _ m a x N s l i p F a m i l y                                                                   !   l o o p   o v e r   a l l   s l i p   f a m i l i e s 
       i n d e x _ m y F a m i l y   =   s u m ( l a t t i c e _ N s l i p S y s t e m ( 1 : f - 1 , m y S t r u c t u r e ) )   !   a t   w h i c h   i n d e x   s t a r t s   m y   f a m i l y 
       d o   i   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( f , m y I n s t a n c e )                     !   p r o c e s s   e a c h   ( a c t i v e )   s l i p   s y s t e m   i n   f a m i l y 
             j   =   j + 1 _ p I n t 
 
             ! *   C a l c u l a t i o n   o f   L p 
             ! *   R e s o l v e d   s h e a r   s t r e s s   o n   s l i p   s y s t e m 
             t a u _ s l i p ( j )   =   d o t _ p r o d u c t ( T s t a r _ v , l a t t i c e _ S s l i p _ v ( : , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) ) 
 
             ! *   S t r e s s   r a t i o s 
             S t r e s s R a t i o _ p   =   ( a b s ( t a u _ s l i p ( j ) ) / s t a t e ( g , i p , e l ) % p ( 5 * n s + 3 * n t + j ) ) * * c o n s t i t u t i v e _ d i s l o t w i n _ p ( m y I n s t a n c e ) 
             S t r e s s R a t i o _ p m i n u s 1   =   ( a b s ( t a u _ s l i p ( j ) ) / s t a t e ( g , i p , e l ) % p ( 5 * n s + 3 * n t + j ) ) * * ( c o n s t i t u t i v e _ d i s l o t w i n _ p ( m y I n s t a n c e ) - 1 . 0 _ p R e a l ) 
             ! *   B o l t z m a n n   r a t i o 
             B o l t z m a n n R a t i o   =   c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p S y s t e m ( f , m y I n s t a n c e ) / ( k B * T e m p e r a t u r e ) 
             ! *   I n i t i a l   s h e a r   r a t e s 
             D o t G a m m a 0   =   & 
                 s t a t e ( g , i p , e l ) % p ( j ) * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( f , m y I n s t a n c e ) * & 
                 c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p S y s t e m ( f , m y I n s t a n c e ) 
 
             ! *   S h e a r   r a t e s   d u e   t o   s l i p 
             g d o t _ s l i p ( j )   =   D o t G a m m a 0 * e x p ( - B o l t z m a n n R a t i o * ( 1 - S t r e s s R a t i o _ p ) * * c o n s t i t u t i v e _ d i s l o t w i n _ q ( m y I n s t a n c e ) ) * & 
                                           s i g n ( 1 . 0 _ p R e a l , t a u _ s l i p ( j ) ) 
 
             ! *   D e r i v a t i v e s   o f   s h e a r   r a t e s 
             d g d o t _ d t a u s l i p ( j )   =   & 
                 ( ( a b s ( g d o t _ s l i p ( j ) ) * B o l t z m a n n R a t i o * & 
                 c o n s t i t u t i v e _ d i s l o t w i n _ p ( m y I n s t a n c e ) * c o n s t i t u t i v e _ d i s l o t w i n _ q ( m y I n s t a n c e ) ) / s t a t e ( g , i p , e l ) % p ( 5 * n s + 3 * n t + j ) ) * & 
                 S t r e s s R a t i o _ p m i n u s 1 * ( 1 - S t r e s s R a t i o _ p ) * * ( c o n s t i t u t i v e _ d i s l o t w i n _ q ( m y I n s t a n c e ) - 1 . 0 _ p R e a l ) 
 
             ! *   P l a s t i c   v e l o c i t y   g r a d i e n t   f o r   d i s l o c a t i o n   g l i d e 
             L p   =   L p   +   ( 1 . 0 _ p R e a l   -   s u m f ) * g d o t _ s l i p ( j ) * l a t t i c e _ S s l i p ( : , : , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) 
 
             ! *   C a l c u l a t i o n   o f   t h e   t a n g e n t   o f   L p 
             f o r a l l   ( k = 1 : 3 , l = 1 : 3 , m = 1 : 3 , n = 1 : 3 )   & 
                 d L p _ d T s t a r 3 3 3 3 ( k , l , m , n )   =   & 
                 d L p _ d T s t a r 3 3 3 3 ( k , l , m , n )   +   d g d o t _ d t a u s l i p ( j ) * & 
                                                                     l a t t i c e _ S s l i p ( k , l , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) * & 
                                                                     l a t t i c e _ S s l i p ( m , n , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) 
       e n d d o 
 e n d d o 
 
 ! *   M e c h a n i c a l   t w i n n i n g   p a r t 
 g d o t _ t w i n   =   0 . 0 _ p R e a l 
 d g d o t _ d t a u t w i n   =   0 . 0 _ p R e a l 
 j   =   0 _ p I n t 
 d o   f   =   1 , l a t t i c e _ m a x N t w i n F a m i l y                                                                   !   l o o p   o v e r   a l l   s l i p   f a m i l i e s 
       i n d e x _ m y F a m i l y   =   s u m ( l a t t i c e _ N t w i n S y s t e m ( 1 : f - 1 , m y S t r u c t u r e ) )   !   a t   w h i c h   i n d e x   s t a r t s   m y   f a m i l y 
       d o   i   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ( f , m y I n s t a n c e )                     !   p r o c e s s   e a c h   ( a c t i v e )   s l i p   s y s t e m   i n   f a m i l y 
             j   =   j + 1 _ p I n t 
 
             ! *   C a l c u l a t i o n   o f   L p 
             ! *   R e s o l v e d   s h e a r   s t r e s s   o n   t w i n   s y s t e m 
             t a u _ t w i n ( j )   =   d o t _ p r o d u c t ( T s t a r _ v , l a t t i c e _ S t w i n _ v ( : , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) ) 
 
             ! *   S t r e s s   r a t i o s 
             S t r e s s R a t i o _ r   =   ( s t a t e ( g , i p , e l ) % p ( 6 * n s + 3 * n t + j ) / t a u _ t w i n ( j ) ) * * c o n s t i t u t i v e _ d i s l o t w i n _ r ( m y I n s t a n c e ) 
 
             ! *   S h e a r   r a t e s   a n d   t h e i r   d e r i v a t i v e s   d u e   t o   t w i n 
             i f   (   t a u _ t w i n ( j )   >   0 . 0 _ p R e a l   )   t h e n 
                 g d o t _ t w i n ( j )   =   & 
                     ( c o n s t i t u t i v e _ d i s l o t w i n _ M a x T w i n F r a c t i o n ( m y I n s t a n c e ) - s u m f ) * l a t t i c e _ s h e a r T w i n ( i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) * & 
                     s t a t e ( g , i p , e l ) % p ( 6 * n s + 4 * n t + j ) * c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n S y s t e m ( f , m y I n s t a n c e ) * e x p ( - S t r e s s R a t i o _ r ) 
                 d g d o t _ d t a u t w i n ( j )   =   ( ( g d o t _ t w i n ( j ) * c o n s t i t u t i v e _ d i s l o t w i n _ r ( m y I n s t a n c e ) ) / t a u _ t w i n ( j ) ) * S t r e s s R a t i o _ r 
             e n d i f 
 
             ! *   P l a s t i c   v e l o c i t y   g r a d i e n t   f o r   m e c h a n i c a l   t w i n n i n g 
             L p   =   L p   +   g d o t _ t w i n ( j ) * l a t t i c e _ S t w i n ( : , : , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) 
 
             ! *   C a l c u l a t i o n   o f   t h e   t a n g e n t   o f   L p 
             f o r a l l   ( k = 1 : 3 , l = 1 : 3 , m = 1 : 3 , n = 1 : 3 )   & 
                 d L p _ d T s t a r 3 3 3 3 ( k , l , m , n )   =   & 
                 d L p _ d T s t a r 3 3 3 3 ( k , l , m , n )   +   d g d o t _ d t a u t w i n ( j ) * & 
                                                                     l a t t i c e _ S t w i n ( k , l , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) * & 
                                                                     l a t t i c e _ S t w i n ( m , n , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) 
       e n d d o 
 e n d d o 
 
 d L p _ d T s t a r   =   m a t h _ P l a i n 3 3 3 3 t o 9 9 ( d L p _ d T s t a r 3 3 3 3 ) 
 
 ! i f   ( ( i p = = 1 ) . a n d . ( e l = = 1 ) )   t h e n 
 !       w r i t e ( 6 , * )   ' # L P / T A N G E N T # ' 
 !       w r i t e ( 6 , * ) 
 !       w r i t e ( 6 , * )   ' T s t a r _ v ' ,   T s t a r _ v 
 !       w r i t e ( 6 , * )   ' t a u _ s l i p ' ,   t a u _ s l i p 
 !       w r i t e ( 6 , ' ( a 1 0 , / , 4 ( 3 ( e 2 0 . 8 , x ) , / ) ) ' )   ' s t a t e ' , s t a t e ( 1 , 1 , 1 ) % p 
 !       w r i t e ( 6 , ' ( a , / , 3 ( 3 ( f 1 0 . 4 , x ) / ) ) ' )   ' L p ' , L p 
 !       w r i t e ( 6 , ' ( a , / , 9 ( 9 ( f 1 0 . 4 , x ) / ) ) ' )   ' d L p _ d T s t a r ' , d L p _ d T s t a r 
 ! e n d i f 
 
 r e t u r n 
 e n d   s u b r o u t i n e 
 
 
 f u n c t i o n   c o n s t i t u t i v e _ d i s l o t w i n _ d o t S t a t e ( T s t a r _ v , T e m p e r a t u r e , s t a t e , g , i p , e l ) 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 ! *   r a t e   o f   c h a n g e   o f   m i c r o s t r u c t u r e                                                                     * 
 ! *   I N P U T :                                                                                                                         * 
 ! *     -   T e m p e r a t u r e           :   t e m p e r a t u r e                                                                     * 
 ! *     -   s t a t e                       :   m i c r o s t r u c t u r e   q u a n t i t i e s                                         * 
 ! *     -   T s t a r _ v                   :   2 n d   P i o l a   K i r c h h o f f   s t r e s s   t e n s o r   ( M a n d e l )       * 
 ! *     -   i p c                           :   c o m p o n e n t - I D   a t   c u r r e n t   i n t e g r a t i o n   p o i n t         * 
 ! *     -   i p                             :   c u r r e n t   i n t e g r a t i o n   p o i n t                                         * 
 ! *     -   e l                             :   c u r r e n t   e l e m e n t                                                             * 
 ! *   O U T P U T :                                                                                                                       * 
 ! *     -   c o n s t i t u t i v e _ d o t S t a t e   :   e v o l u t i o n   o f   s t a t e   v a r i a b l e                         * 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 u s e   p r e c ,           o n l y :   p R e a l , p I n t , p _ v e c 
 
 u s e   m a t h ,           o n l y :   p i 
 u s e   m e s h ,           o n l y :   m e s h _ N c p E l e m s ,   m e s h _ m a x N i p s 
 u s e   m a t e r i a l ,   o n l y :   h o m o g e n i z a t i o n _ m a x N g r a i n s ,   m a t e r i a l _ p h a s e ,   p h a s e _ c o n s t i t u t i o n I n s t a n c e 
 u s e   l a t t i c e ,     o n l y :   l a t t i c e _ S s l i p , l a t t i c e _ S s l i p _ v ,   & 
                                         l a t t i c e _ S t w i n , l a t t i c e _ S t w i n _ v ,   & 
                                         l a t t i c e _ m a x N s l i p F a m i l y , l a t t i c e _ m a x N t w i n F a m i l y ,   & 
                                         l a t t i c e _ N s l i p S y s t e m , l a t t i c e _ N t w i n S y s t e m ,   & 
                                         l a t t i c e _ s h e a r T w i n 
 i m p l i c i t   n o n e 
 
 ! *   I n p u t - O u t p u t   v a r i a b l e s 
 i n t e g e r ( p I n t ) ,   i n t e n t ( i n )   : :   g , i p , e l 
 r e a l ( p R e a l ) ,   i n t e n t ( i n )   : :   T e m p e r a t u r e 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( 6 ) ,   i n t e n t ( i n )   : :   T s t a r _ v 
 t y p e ( p _ v e c ) ,   d i m e n s i o n ( h o m o g e n i z a t i o n _ m a x N g r a i n s , m e s h _ m a x N i p s , m e s h _ N c p E l e m s ) ,   i n t e n t ( i n )   : :   s t a t e 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( c o n s t i t u t i v e _ d i s l o t w i n _ s i z e D o t S t a t e ( p h a s e _ c o n s t i t u t i o n I n s t a n c e ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) ) )   : :   & 
 c o n s t i t u t i v e _ d i s l o t w i n _ d o t S t a t e 
 ! *   L o c a l   v a r i a b l e s 
 i n t e g e r ( p I n t )   M y I n s t a n c e , M y S t r u c t u r e , n s , n t , f , i , j , i n d e x _ m y F a m i l y 
 r e a l ( p R e a l )   s u m f , S t r e s s R a t i o _ p , S t r e s s R a t i o _ p m i n u s 1 , B o l t z m a n n R a t i o , D o t G a m m a 0 , & 
                         E d g e D i p M i n D i s t a n c e , A t o m i c V o l u m e , V a c a n c y D i f f u s i o n , S t r e s s R a t i o _ r 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( p h a s e _ c o n s t i t u t i o n I n s t a n c e ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) ) )   : :   & 
 g d o t _ s l i p , t a u _ s l i p , D o t R h o M u l t i p l i c a t i o n , E d g e D i p D i s t a n c e , D o t R h o E d g e E d g e A n n i h i l a t i o n , D o t R h o E d g e D i p A n n i h i l a t i o n , & 
 
 C l i m b V e l o c i t y , D o t R h o E d g e D i p C l i m b , D o t R h o D i p F o r m a t i o n 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( p h a s e _ c o n s t i t u t i o n I n s t a n c e ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) ) )   : :   & 
                           t a u _ t w i n 
 
 ! *   S h o r t e n e d   n o t a t i o n 
 m y I n s t a n c e     =   p h a s e _ c o n s t i t u t i o n I n s t a n c e ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) 
 M y S t r u c t u r e   =   c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e ( m y I n s t a n c e ) 
 n s   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( m y I n s t a n c e ) 
 n t   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( m y I n s t a n c e ) 
 
 ! *   T o t a l   t w i n   v o l u m e   f r a c t i o n 
 s u m f   =   s u m ( s t a t e ( g , i p , e l ) % p ( ( 2 * n s + 1 ) : ( 2 * n s + n t ) ) )   !   s a f e   f o r   n t   = =   0 
 
 c o n s t i t u t i v e _ d i s l o t w i n _ d o t S t a t e   =   0 . 0 _ p R e a l 
 
 ! *   D i s l o c a t i o n   d e n s i t y   e v o l u t i o n 
 g d o t _ s l i p   =   0 . 0 _ p R e a l 
 j   =   0 _ p I n t 
 d o   f   =   1 , l a t t i c e _ m a x N s l i p F a m i l y                                                                   !   l o o p   o v e r   a l l   s l i p   f a m i l i e s 
       i n d e x _ m y F a m i l y   =   s u m ( l a t t i c e _ N s l i p S y s t e m ( 1 : f - 1 , M y S t r u c t u r e ) )   !   a t   w h i c h   i n d e x   s t a r t s   m y   f a m i l y 
       d o   i   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( f , m y I n s t a n c e )                     !   p r o c e s s   e a c h   ( a c t i v e )   s l i p   s y s t e m   i n   f a m i l y 
             j   =   j + 1 _ p I n t 
 
 
             ! *   R e s o l v e d   s h e a r   s t r e s s   o n   s l i p   s y s t e m 
             t a u _ s l i p ( j )   =   d o t _ p r o d u c t ( T s t a r _ v , l a t t i c e _ S s l i p _ v ( : , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) ) 
             ! *   S t r e s s   r a t i o s 
             S t r e s s R a t i o _ p   =   ( a b s ( t a u _ s l i p ( j ) ) / s t a t e ( g , i p , e l ) % p ( 5 * n s + 3 * n t + j ) ) * * c o n s t i t u t i v e _ d i s l o t w i n _ p ( m y I n s t a n c e ) 
             S t r e s s R a t i o _ p m i n u s 1   =   ( a b s ( t a u _ s l i p ( j ) ) / s t a t e ( g , i p , e l ) % p ( 5 * n s + 3 * n t + j ) ) * * ( c o n s t i t u t i v e _ d i s l o t w i n _ p ( m y I n s t a n c e ) - 1 . 0 _ p R e a l ) 
             ! *   B o l t z m a n n   r a t i o 
             B o l t z m a n n R a t i o   =   c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p S y s t e m ( f , m y I n s t a n c e ) / ( k B * T e m p e r a t u r e ) 
             ! *   I n i t i a l   s h e a r   r a t e s 
             D o t G a m m a 0   =   & 
                 s t a t e ( g , i p , e l ) % p ( j ) * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( f , m y I n s t a n c e ) * & 
                 c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p S y s t e m ( f , m y I n s t a n c e ) 
 
             ! *   S h e a r   r a t e s   d u e   t o   s l i p 
             g d o t _ s l i p ( j )   =   D o t G a m m a 0 * e x p ( - B o l t z m a n n R a t i o * ( 1 - S t r e s s R a t i o _ p ) * * c o n s t i t u t i v e _ d i s l o t w i n _ q ( m y I n s t a n c e ) ) * & 
                                           s i g n ( 1 . 0 _ p R e a l , t a u _ s l i p ( j ) ) 
 
             ! *   M u l t i p l i c a t i o n 
             D o t R h o M u l t i p l i c a t i o n ( j )   =   a b s ( g d o t _ s l i p ( j ) ) / & 
                                                                 ( c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( f , m y I n s t a n c e ) * s t a t e ( g , i p , e l ) % p ( 4 * n s + 2 * n t + j ) ) 
 
             ! *   D i p o l e   f o r m a t i o n 
             E d g e D i p M i n D i s t a n c e   =   & 
                 c o n s t i t u t i v e _ d i s l o t w i n _ C E d g e D i p M i n D i s t a n c e ( m y I n s t a n c e ) * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( f , m y I n s t a n c e ) 
             i f   ( t a u _ s l i p ( j )   = =   0 . 0 _ p R e a l )   t h e n 
                 D o t R h o D i p F o r m a t i o n ( j )   =   0 . 0 _ p R e a l 
             e l s e 
                 E d g e D i p D i s t a n c e ( j )   =   & 
                     ( 3 . 0 _ p R e a l * c o n s t i t u t i v e _ d i s l o t w i n _ G m o d ( m y I n s t a n c e ) * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( f , m y I n s t a n c e ) ) / & 
                     ( 1 6 . 0 _ p R e a l * p i * a b s ( t a u _ s l i p ( j ) ) ) 
             i f   ( E d g e D i p D i s t a n c e ( j ) > s t a t e ( g , i p , e l ) % p ( 4 * n s + 2 * n t + j ) )   E d g e D i p D i s t a n c e ( j ) = s t a t e ( g , i p , e l ) % p ( 4 * n s + 2 * n t + j ) 
             i f   ( E d g e D i p D i s t a n c e ( j ) < E d g e D i p M i n D i s t a n c e )   E d g e D i p D i s t a n c e ( j ) = E d g e D i p M i n D i s t a n c e 
                 D o t R h o D i p F o r m a t i o n ( j )   =   & 
                     ( ( 2 . 0 _ p R e a l * E d g e D i p D i s t a n c e ( j ) ) / c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( f , m y I n s t a n c e ) ) * & 
                     s t a t e ( g , i p , e l ) % p ( j ) * a b s ( g d o t _ s l i p ( j ) ) 
             e n d i f 
 
             ! *   S p o n t a n e o u s   a n n i h i l a t i o n   o f   2   s i n g l e   e d g e   d i s l o c a t i o n s 
             D o t R h o E d g e E d g e A n n i h i l a t i o n ( j )   =   & 
                 ( ( 2 . 0 _ p R e a l * E d g e D i p M i n D i s t a n c e ) / c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( f , m y I n s t a n c e ) ) * & 
                 s t a t e ( g , i p , e l ) % p ( j ) * a b s ( g d o t _ s l i p ( j ) ) 
 
             ! *   S p o n t a n e o u s   a n n i h i l a t i o n   o f   a   s i n g l e   e d g e   d i s l o c a t i o n   w i t h   a   d i p o l e   c o n s t i t u e n t 
             D o t R h o E d g e D i p A n n i h i l a t i o n ( j )   =   & 
                 ( ( 2 . 0 _ p R e a l * E d g e D i p M i n D i s t a n c e ) / c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( f , m y I n s t a n c e ) ) * & 
                 s t a t e ( g , i p , e l ) % p ( n s + j ) * a b s ( g d o t _ s l i p ( j ) ) 
 
             ! *   D i s l o c a t i o n   d i p o l e   c l i m b 
             A t o m i c V o l u m e   =   & 
                 c o n s t i t u t i v e _ d i s l o t w i n _ C A t o m i c V o l u m e ( m y I n s t a n c e ) * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( f , m y I n s t a n c e ) * * ( 3 . 0 _ p R e a l ) 
             V a c a n c y D i f f u s i o n   =   & 
                 c o n s t i t u t i v e _ d i s l o t w i n _ D 0 ( m y I n s t a n c e ) * e x p ( - c o n s t i t u t i v e _ d i s l o t w i n _ Q s d ( m y I n s t a n c e ) / ( k B * T e m p e r a t u r e ) ) 
             i f   ( t a u _ s l i p ( j )   = =   0 . 0 _ p R e a l )   t h e n 
                 D o t R h o E d g e D i p C l i m b ( j )   =   0 . 0 _ p R e a l 
             e l s e 
                 C l i m b V e l o c i t y ( j )   =   & 
                     ( ( 3 . 0 _ p R e a l * c o n s t i t u t i v e _ d i s l o t w i n _ G m o d ( m y I n s t a n c e ) * V a c a n c y D i f f u s i o n * A t o m i c V o l u m e ) / ( 2 . 0 _ p R e a l * p i * k B * T e m p e r a t u r e ) ) * & 
                     ( 1 / ( E d g e D i p D i s t a n c e ( j ) + E d g e D i p M i n D i s t a n c e ) ) 
                 D o t R h o E d g e D i p C l i m b ( j )   =   & 
                     ( 4 . 0 _ p R e a l * C l i m b V e l o c i t y ( j ) * s t a t e ( g , i p , e l ) % p ( n s + j ) ) / ( E d g e D i p D i s t a n c e ( j ) - E d g e D i p M i n D i s t a n c e ) 
             e n d i f 
 
             ! *   E d g e   d i s l o c a t i o n   d e n s i t y   r a t e   o f   c h a n g e 
             c o n s t i t u t i v e _ d i s l o t w i n _ d o t S t a t e ( j )   =   & 
                 D o t R h o M u l t i p l i c a t i o n ( j ) - D o t R h o D i p F o r m a t i o n ( j ) - D o t R h o E d g e E d g e A n n i h i l a t i o n ( j ) 
 
             ! *   E d g e   d i s l o c a t i o n   d i p o l e   d e n s i t y   r a t e   o f   c h a n g e 
             c o n s t i t u t i v e _ d i s l o t w i n _ d o t S t a t e ( n s + j )   =   & 
                 D o t R h o D i p F o r m a t i o n ( j ) - D o t R h o E d g e D i p A n n i h i l a t i o n ( j ) - D o t R h o E d g e D i p C l i m b ( j ) 
 
       e n d d o 
 e n d d o 
 
 ! *   T w i n   v o l u m e   f r a c t i o n   e v o l u t i o n 
 j   =   0 _ p I n t 
 d o   f   =   1 , l a t t i c e _ m a x N t w i n F a m i l y                                                                   !   l o o p   o v e r   a l l   t w i n   f a m i l i e s 
       i n d e x _ m y F a m i l y   =   s u m ( l a t t i c e _ N t w i n S y s t e m ( 1 : f - 1 , M y S t r u c t u r e ) )   !   a t   w h i c h   i n d e x   s t a r t s   m y   f a m i l y 
       d o   i   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ( f , m y I n s t a n c e )                     !   p r o c e s s   e a c h   ( a c t i v e )   t w i n   s y s t e m   i n   f a m i l y 
             j   =   j + 1 _ p I n t 
 
             ! *   R e s o l v e d   s h e a r   s t r e s s   o n   t w i n   s y s t e m 
             t a u _ t w i n ( j )   =   d o t _ p r o d u c t ( T s t a r _ v , l a t t i c e _ S t w i n _ v ( : , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) ) 
             ! *   S t r e s s   r a t i o s 
             S t r e s s R a t i o _ r   =   ( s t a t e ( g , i p , e l ) % p ( 6 * n s + 3 * n t + j ) / t a u _ t w i n ( j ) ) * * c o n s t i t u t i v e _ d i s l o t w i n _ r ( m y I n s t a n c e ) 
 
             ! *   S h e a r   r a t e s   a n d   t h e i r   d e r i v a t i v e s   d u e   t o   t w i n 
             i f   (   t a u _ t w i n ( j )   >   0 . 0 _ p R e a l   )   t h e n 
                 c o n s t i t u t i v e _ d i s l o t w i n _ d o t S t a t e ( 2 * n s + j )   =   & 
                     ( c o n s t i t u t i v e _ d i s l o t w i n _ M a x T w i n F r a c t i o n ( m y I n s t a n c e ) - s u m f ) * & 
                     s t a t e ( g , i p , e l ) % p ( 6 * n s + 4 * n t + j ) * c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n S y s t e m ( f , m y I n s t a n c e ) * e x p ( - S t r e s s R a t i o _ r ) 
             e n d i f 
 
       e n d d o 
 e n d d o 
 
 ! w r i t e ( 6 , * )   ' # D O T S T A T E # ' 
 ! w r i t e ( 6 , * ) 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' t a u   s l i p ' , t a u _ s l i p 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' g a m m a   s l i p ' , g d o t _ s l i p 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' R h o E d g e ' , s t a t e ( g , i p , e l ) % p ( 1 : n s ) 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' T h r e s h o l d   S l i p ' ,   s t a t e ( g , i p , e l ) % p ( 5 * n s + 3 * n t + 1 : 6 * n s + 3 * n t ) 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' M u l t i p l i c a t i o n ' , D o t R h o M u l t i p l i c a t i o n 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' D i p F o r m a t i o n ' , D o t R h o D i p F o r m a t i o n 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' S i n g l e S i n g l e ' , D o t R h o E d g e E d g e A n n i h i l a t i o n 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' S i n g l e D i p o l e ' , D o t R h o E d g e D i p A n n i h i l a t i o n 
 ! w r i t e ( 6 , ' ( a , / , 4 ( 3 ( f 3 0 . 2 0 , x ) / ) ) ' )   ' D i p C l i m b ' , D o t R h o E d g e D i p C l i m b 
 
 r e t u r n 
 e n d   f u n c t i o n 
 
 
 p u r e   f u n c t i o n   c o n s t i t u t i v e _ d i s l o t w i n _ d o t T e m p e r a t u r e ( T s t a r _ v , T e m p e r a t u r e , s t a t e , g , i p , e l ) 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 ! *   r a t e   o f   c h a n g e   o f   m i c r o s t r u c t u r e                                                                     * 
 ! *   I N P U T :                                                                                                                         * 
 ! *     -   T e m p e r a t u r e           :   t e m p e r a t u r e                                                                     * 
 ! *     -   T s t a r _ v                   :   2 n d   P i o l a   K i r c h h o f f   s t r e s s   t e n s o r   ( M a n d e l )       * 
 ! *     -   i p c                           :   c o m p o n e n t - I D   a t   c u r r e n t   i n t e g r a t i o n   p o i n t         * 
 ! *     -   i p                             :   c u r r e n t   i n t e g r a t i o n   p o i n t                                         * 
 ! *     -   e l                             :   c u r r e n t   e l e m e n t                                                             * 
 ! *   O U T P U T :                                                                                                                       * 
 ! *     -   c o n s t i t u t i v e _ d o t T e m p e r a t u r e   :   e v o l u t i o n   o f   T e m p e r a t u r e                   * 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 u s e   p r e c ,           o n l y :   p R e a l , p I n t , p _ v e c 
 u s e   m e s h ,           o n l y :   m e s h _ N c p E l e m s , m e s h _ m a x N i p s 
 u s e   m a t e r i a l ,   o n l y :   h o m o g e n i z a t i o n _ m a x N g r a i n s 
 i m p l i c i t   n o n e 
 
 ! *   I n p u t - O u t p u t   v a r i a b l e s 
 i n t e g e r ( p I n t ) ,   i n t e n t ( i n )   : :   g , i p , e l 
 r e a l ( p R e a l ) ,   i n t e n t ( i n )   : :   T e m p e r a t u r e 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( 6 ) ,   i n t e n t ( i n )   : :   T s t a r _ v 
 t y p e ( p _ v e c ) ,   d i m e n s i o n ( h o m o g e n i z a t i o n _ m a x N g r a i n s , m e s h _ m a x N i p s , m e s h _ N c p E l e m s ) ,   i n t e n t ( i n )   : :   s t a t e 
 r e a l ( p R e a l )   c o n s t i t u t i v e _ d i s l o t w i n _ d o t T e m p e r a t u r e 
 
 c o n s t i t u t i v e _ d i s l o t w i n _ d o t T e m p e r a t u r e   =   0 . 0 _ p R e a l 
 
 r e t u r n 
 e n d   f u n c t i o n 
 
 
 p u r e   f u n c t i o n   c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( T s t a r _ v , T e m p e r a t u r e , d t , s t a t e , g , i p , e l ) 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 ! *   r e t u r n   a r r a y   o f   c o n s t i t u t i v e   r e s u l t s                                                             * 
 ! *   I N P U T :                                                                                                                         * 
 ! *     -   T e m p e r a t u r e           :   t e m p e r a t u r e                                                                     * 
 ! *     -   T s t a r _ v                   :   2 n d   P i o l a   K i r c h h o f f   s t r e s s   t e n s o r   ( M a n d e l )       * 
 ! *     -   d t                             :   c u r r e n t   t i m e   i n c r e m e n t                                               * 
 ! *     -   i p c                           :   c o m p o n e n t - I D   a t   c u r r e n t   i n t e g r a t i o n   p o i n t         * 
 ! *     -   i p                             :   c u r r e n t   i n t e g r a t i o n   p o i n t                                         * 
 ! *     -   e l                             :   c u r r e n t   e l e m e n t                                                             * 
 ! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 u s e   p r e c ,           o n l y :   p R e a l , p I n t , p _ v e c 
 u s e   m a t h ,           o n l y :   p i 
 u s e   m e s h ,           o n l y :   m e s h _ N c p E l e m s , m e s h _ m a x N i p s 
 u s e   m a t e r i a l ,   o n l y :   h o m o g e n i z a t i o n _ m a x N g r a i n s , m a t e r i a l _ p h a s e , p h a s e _ c o n s t i t u t i o n I n s t a n c e , p h a s e _ N o u t p u t 
 u s e   l a t t i c e ,     o n l y :   l a t t i c e _ S s l i p _ v , l a t t i c e _ S t w i n _ v , l a t t i c e _ m a x N s l i p F a m i l y , l a t t i c e _ m a x N t w i n F a m i l y ,   & 
                                         l a t t i c e _ N s l i p S y s t e m , l a t t i c e _ N t w i n S y s t e m , l a t t i c e _ s h e a r T w i n 
 i m p l i c i t   n o n e 
 
 ! *   D e f i n i t i o n   o f   v a r i a b l e s 
 i n t e g e r ( p I n t ) ,   i n t e n t ( i n )   : :   g , i p , e l 
 r e a l ( p R e a l ) ,   i n t e n t ( i n )   : :   d t , T e m p e r a t u r e 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( 6 ) ,   i n t e n t ( i n )   : :   T s t a r _ v 
 t y p e ( p _ v e c ) ,   d i m e n s i o n ( h o m o g e n i z a t i o n _ m a x N g r a i n s , m e s h _ m a x N i p s , m e s h _ N c p E l e m s ) ,   i n t e n t ( i n )   : :   s t a t e 
 i n t e g e r ( p I n t )   m y I n s t a n c e , m y S t r u c t u r e , n s , n t , f , o , i , c , j , i n d e x _ m y F a m i l y 
 r e a l ( p R e a l )   s u m f , t a u , S t r e s s R a t i o _ p , S t r e s s R a t i o _ p m i n u s 1 , B o l t z m a n n R a t i o , D o t G a m m a 0 , S t r e s s R a t i o _ r , g d o t _ s l i p , d g d o t _ d t a u s l i p 
 r e a l ( p R e a l ) ,   d i m e n s i o n ( c o n s t i t u t i v e _ d i s l o t w i n _ s i z e P o s t R e s u l t s ( p h a s e _ c o n s t i t u t i o n I n s t a n c e ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) ) )   : :   & 
 c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s 
 
 ! *   S h o r t e n e d   n o t a t i o n 
 m y I n s t a n c e     =   p h a s e _ c o n s t i t u t i o n I n s t a n c e ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) 
 m y S t r u c t u r e   =   c o n s t i t u t i v e _ d i s l o t w i n _ s t r u c t u r e ( m y I n s t a n c e ) 
 n s   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N s l i p ( m y I n s t a n c e ) 
 n t   =   c o n s t i t u t i v e _ d i s l o t w i n _ t o t a l N t w i n ( m y I n s t a n c e ) 
 
 ! *   T o t a l   t w i n   v o l u m e   f r a c t i o n 
 s u m f   =   s u m ( s t a t e ( g , i p , e l ) % p ( ( 2 * n s + 1 ) : ( 2 * n s + n t ) ) )   !   s a f e   f o r   n t   = =   0 
 
 ! *   R e q u i r e d   o u t p u t 
 c   =   0 _ p I n t 
 c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s   =   0 . 0 _ p R e a l 
 
 d o   o   =   1 , p h a s e _ N o u t p u t ( m a t e r i a l _ p h a s e ( g , i p , e l ) ) 
       s e l e c t   c a s e ( c o n s t i t u t i v e _ d i s l o t w i n _ o u t p u t ( o , m y I n s t a n c e ) ) 
 
           c a s e   ( ' e d g e _ d e n s i t y ' ) 
               c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + 1 : c + n s )   =   s t a t e ( g , i p , e l ) % p ( 1 : n s ) 
               c   =   c   +   n s 
           c a s e   ( ' d i p o l e _ d e n s i t y ' ) 
               c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + 1 : c + n s )   =   s t a t e ( g , i p , e l ) % p ( n s + 1 : 2 * n s ) 
               c   =   c   +   n s 
           c a s e   ( ' s h e a r _ r a t e _ s l i p ' ) 
               j   =   0 _ p I n t 
               d o   f   =   1 , l a t t i c e _ m a x N s l i p F a m i l y                                                                   !   l o o p   o v e r   a l l   s l i p   f a m i l i e s 
                     i n d e x _ m y F a m i l y   =   s u m ( l a t t i c e _ N s l i p S y s t e m ( 1 : f - 1 , m y S t r u c t u r e ) )   !   a t   w h i c h   i n d e x   s t a r t s   m y   f a m i l y 
                     d o   i   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( f , m y I n s t a n c e )                     !   p r o c e s s   e a c h   ( a c t i v e )   s l i p   s y s t e m   i n   f a m i l y 
                           j   =   j   +   1 _ p I n t 
 
                           ! *   R e s o l v e d   s h e a r   s t r e s s   o n   s l i p   s y s t e m 
                           t a u   =   d o t _ p r o d u c t ( T s t a r _ v , l a t t i c e _ S s l i p _ v ( : , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) ) 
                           ! *   S t r e s s   r a t i o s 
                           S t r e s s R a t i o _ p   =   ( a b s ( t a u ) / s t a t e ( g , i p , e l ) % p ( 5 * n s + 3 * n t + j ) ) * * c o n s t i t u t i v e _ d i s l o t w i n _ p ( m y I n s t a n c e ) 
                           S t r e s s R a t i o _ p m i n u s 1   =   ( a b s ( t a u ) / s t a t e ( g , i p , e l ) % p ( 5 * n s + 3 * n t + j ) ) * * ( c o n s t i t u t i v e _ d i s l o t w i n _ p ( m y I n s t a n c e ) - 1 . 0 _ p R e a l ) 
                           ! *   B o l t z m a n n   r a t i o 
                           B o l t z m a n n R a t i o   =   c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p S y s t e m ( f , m y I n s t a n c e ) / ( k B * T e m p e r a t u r e ) 
                           ! *   I n i t i a l   s h e a r   r a t e s 
                           D o t G a m m a 0   =   & 
                               s t a t e ( g , i p , e l ) % p ( j ) * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( f , m y I n s t a n c e ) *   & 
                               c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p S y s t e m ( f , m y I n s t a n c e ) 
 
                           ! *   S h e a r   r a t e s   d u e   t o   s l i p 
                           c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + j )   =   & 
                               D o t G a m m a 0 * e x p ( - B o l t z m a n n R a t i o * ( 1 - S t r e s s R a t i o _ p ) * * c o n s t i t u t i v e _ d i s l o t w i n _ q ( m y I n s t a n c e ) ) * s i g n ( 1 . 0 _ p R e a l , t a u ) 
               e n d d o   ;   e n d d o 
               c   =   c   +   n s 
           c a s e   ( ' m f p _ s l i p ' ) 
               c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + 1 : c + n s )   =   s t a t e ( g , i p , e l ) % p ( ( 4 * n s + 2 * n t + 1 ) : ( 5 * n s + 2 * n t ) ) 
               c   =   c   +   n s 
           c a s e   ( ' r e s o l v e d _ s t r e s s _ s l i p ' ) 
               j   =   0 _ p I n t 
               d o   f   =   1 , l a t t i c e _ m a x N s l i p F a m i l y                                                                   !   l o o p   o v e r   a l l   s l i p   f a m i l i e s 
                     i n d e x _ m y F a m i l y   =   s u m ( l a t t i c e _ N s l i p S y s t e m ( 1 : f - 1 , m y S t r u c t u r e ) )   !   a t   w h i c h   i n d e x   s t a r t s   m y   f a m i l y 
                     d o   i   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( f , m y I n s t a n c e )                     !   p r o c e s s   e a c h   ( a c t i v e )   s l i p   s y s t e m   i n   f a m i l y 
                           j   =   j   +   1 _ p I n t 
                           c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + j )   =   d o t _ p r o d u c t ( T s t a r _ v , l a t t i c e _ S s l i p _ v ( : , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) ) 
               e n d d o ;   e n d d o 
               c   =   c   +   n s 
           c a s e   ( ' t h r e s h o l d _ s t r e s s _ s l i p ' ) 
               c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + 1 : c + n s )   =   s t a t e ( g , i p , e l ) % p ( ( 5 * n s + 3 * n t + 1 ) : ( 6 * n s + 3 * n t ) ) 
               c   =   c   +   n s 
           c a s e   ( ' e d g e _ d i p o l e _ d i s t a n c e ' ) 
               j   =   0 _ p I n t 
               d o   f   =   1 , l a t t i c e _ m a x N s l i p F a m i l y                                                                   !   l o o p   o v e r   a l l   s l i p   f a m i l i e s 
                     i n d e x _ m y F a m i l y   =   s u m ( l a t t i c e _ N s l i p S y s t e m ( 1 : f - 1 , m y S t r u c t u r e ) )   !   a t   w h i c h   i n d e x   s t a r t s   m y   f a m i l y 
                     d o   i   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( f , m y I n s t a n c e )                     !   p r o c e s s   e a c h   ( a c t i v e )   s l i p   s y s t e m   i n   f a m i l y 
                           j   =   j   +   1 _ p I n t 
                           c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + j )   =   & 
                               ( 3 . 0 _ p R e a l * c o n s t i t u t i v e _ d i s l o t w i n _ G m o d ( m y I n s t a n c e ) * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( f , m y I n s t a n c e ) ) / & 
                               ( 1 6 . 0 _ p R e a l * p i * a b s ( d o t _ p r o d u c t ( T s t a r _ v , l a t t i c e _ S s l i p _ v ( : , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) ) ) ) 
                           c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + j )   =   m i n ( c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + j ) , s t a t e ( g , i p , e l ) % p ( 4 * n s + 2 * n t + j ) ) 
 !                         c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + j )   =   m a x ( c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + j ) , s t a t e ( g , i p , e l ) % p ( 4 * n s + 2 * n t + j ) ) 
               e n d d o ;   e n d d o 
               c   =   c   +   n s 
           c a s e   ( ' t w i n _ f r a c t i o n ' ) 
               c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + 1 : c + n t )   =   s t a t e ( g , i p , e l ) % p ( ( 2 * n s + 1 ) : ( 2 * n s + n t ) ) 
               c   =   c   +   n t 
           c a s e   ( ' s h e a r _ r a t e _ t w i n ' ) 
               i f   ( n t   >   0 _ p I n t )   t h e n 
                   j   =   0 _ p I n t 
                   d o   f   =   1 , l a t t i c e _ m a x N t w i n F a m i l y                                                                   !   l o o p   o v e r   a l l   t w i n   f a m i l i e s 
                       i n d e x _ m y F a m i l y   =   s u m ( l a t t i c e _ N t w i n S y s t e m ( 1 : f - 1 , m y S t r u c t u r e ) )   !   a t   w h i c h   i n d e x   s t a r t s   m y   f a m i l y 
                       d o   i   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ( f , m y I n s t a n c e )                     !   p r o c e s s   e a c h   ( a c t i v e )   t w i n   s y s t e m   i n   f a m i l y 
                           j   =   j   +   1 _ p I n t 
 
                           ! *   R e s o l v e d   s h e a r   s t r e s s   o n   t w i n   s y s t e m 
                           t a u   =   d o t _ p r o d u c t ( T s t a r _ v , l a t t i c e _ S t w i n _ v ( : , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) ) 
                           ! *   S t r e s s   r a t i o s 
                           S t r e s s R a t i o _ r   =   ( s t a t e ( g , i p , e l ) % p ( 6 * n s + 3 * n t + j ) / t a u ) * * c o n s t i t u t i v e _ d i s l o t w i n _ r ( m y I n s t a n c e ) 
 
                           ! *   S h e a r   r a t e s   a n d   t h e i r   d e r i v a t i v e s   d u e   t o   t w i n 
                           i f   (   t a u   >   0 . 0 _ p R e a l   )   t h e n 
                               c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + j )   =   & 
                                   ( c o n s t i t u t i v e _ d i s l o t w i n _ M a x T w i n F r a c t i o n ( m y I n s t a n c e ) - s u m f ) * & 
                                   s t a t e ( g , i p , e l ) % p ( 6 * n s + 4 * n t + j ) * c o n s t i t u t i v e _ d i s l o t w i n _ N d o t 0 P e r T w i n S y s t e m ( f , m y I n s t a n c e ) * e x p ( - S t r e s s R a t i o _ r ) 
                           e n d i f 
 
                   e n d d o   ;   e n d d o 
               e n d i f 
               c   =   c   +   n t 
           c a s e   ( ' m f p _ t w i n ' ) 
               c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + 1 : c + n t )   =   s t a t e ( g , i p , e l ) % p ( ( 5 * n s + 2 * n t + 1 ) : ( 5 * n s + 3 * n t ) ) 
               c   =   c   +   n t 
           c a s e   ( ' r e s o l v e d _ s t r e s s _ t w i n ' ) 
               i f   ( n t   >   0 _ p I n t )   t h e n 
                   j   =   0 _ p I n t 
                   d o   f   =   1 , l a t t i c e _ m a x N t w i n F a m i l y                                                                   !   l o o p   o v e r   a l l   s l i p   f a m i l i e s 
                       i n d e x _ m y F a m i l y   =   s u m ( l a t t i c e _ N t w i n S y s t e m ( 1 : f - 1 , m y S t r u c t u r e ) )     !   a t   w h i c h   i n d e x   s t a r t s   m y   f a m i l y 
                       d o   i   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ N t w i n ( f , m y I n s t a n c e )                       !   p r o c e s s   e a c h   ( a c t i v e )   s l i p   s y s t e m   i n   f a m i l y 
                           j   =   j   +   1 _ p I n t 
                           c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + j )   =   d o t _ p r o d u c t ( T s t a r _ v , l a t t i c e _ S t w i n _ v ( : , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) ) 
                   e n d d o ;   e n d d o 
               e n d i f 
               c   =   c   +   n t 
           c a s e   ( ' t h r e s h o l d _ s t r e s s _ t w i n ' ) 
               c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + 1 : c + n t )   =   s t a t e ( g , i p , e l ) % p ( ( 6 * n s + 3 * n t + 1 ) : ( 6 * n s + 4 * n t ) ) 
               c   =   c   +   n t 
           c a s e   ( ' s t r e s s _ e x p o n e n t ' ) 
               j   =   0 _ p I n t 
               d o   f   =   1 , l a t t i c e _ m a x N s l i p F a m i l y                                                                   !   l o o p   o v e r   a l l   s l i p   f a m i l i e s 
                     i n d e x _ m y F a m i l y   =   s u m ( l a t t i c e _ N s l i p S y s t e m ( 1 : f - 1 , m y S t r u c t u r e ) )   !   a t   w h i c h   i n d e x   s t a r t s   m y   f a m i l y 
                     d o   i   =   1 , c o n s t i t u t i v e _ d i s l o t w i n _ N s l i p ( f , m y I n s t a n c e )                     !   p r o c e s s   e a c h   ( a c t i v e )   s l i p   s y s t e m   i n   f a m i l y 
                           j   =   j   +   1 _ p I n t 
 
                           ! *   R e s o l v e d   s h e a r   s t r e s s   o n   s l i p   s y s t e m 
                           t a u   =   d o t _ p r o d u c t ( T s t a r _ v , l a t t i c e _ S s l i p _ v ( : , i n d e x _ m y F a m i l y + i , m y S t r u c t u r e ) ) 
                           ! *   S t r e s s   r a t i o s 
                           S t r e s s R a t i o _ p   =   ( a b s ( t a u ) / s t a t e ( g , i p , e l ) % p ( 5 * n s + 3 * n t + j ) ) * * c o n s t i t u t i v e _ d i s l o t w i n _ p ( m y I n s t a n c e ) 
                           S t r e s s R a t i o _ p m i n u s 1   =   ( a b s ( t a u ) / s t a t e ( g , i p , e l ) % p ( 5 * n s + 3 * n t + j ) ) * * ( c o n s t i t u t i v e _ d i s l o t w i n _ p ( m y I n s t a n c e ) - 1 . 0 _ p R e a l ) 
                           ! *   B o l t z m a n n   r a t i o 
                           B o l t z m a n n R a t i o   =   c o n s t i t u t i v e _ d i s l o t w i n _ Q e d g e P e r S l i p S y s t e m ( f , m y I n s t a n c e ) / ( k B * T e m p e r a t u r e ) 
                           ! *   I n i t i a l   s h e a r   r a t e s 
                           D o t G a m m a 0   =   & 
                               s t a t e ( g , i p , e l ) % p ( j ) * c o n s t i t u t i v e _ d i s l o t w i n _ b u r g e r s P e r S l i p S y s t e m ( f , m y I n s t a n c e ) *   & 
                               c o n s t i t u t i v e _ d i s l o t w i n _ v 0 P e r S l i p S y s t e m ( f , m y I n s t a n c e ) 
 
                           ! *   S h e a r   r a t e s   d u e   t o   s l i p 
                           g d o t _ s l i p   =   & 
                               D o t G a m m a 0 * e x p ( - B o l t z m a n n R a t i o * ( 1 - S t r e s s R a t i o _ p ) * * c o n s t i t u t i v e _ d i s l o t w i n _ q ( m y I n s t a n c e ) ) * s i g n ( 1 . 0 _ p R e a l , t a u ) 
 
                           ! *   D e r i v a t i v e s   o f   s h e a r   r a t e s 
                           d g d o t _ d t a u s l i p   =   & 
                               ( ( a b s ( g d o t _ s l i p ) * B o l t z m a n n R a t i o * & 
                               c o n s t i t u t i v e _ d i s l o t w i n _ p ( m y I n s t a n c e ) * c o n s t i t u t i v e _ d i s l o t w i n _ q ( m y I n s t a n c e ) ) / s t a t e ( g , i p , e l ) % p ( 5 * n s + 3 * n t + j ) ) * & 
                               S t r e s s R a t i o _ p m i n u s 1 * ( 1 - S t r e s s R a t i o _ p ) * * ( c o n s t i t u t i v e _ d i s l o t w i n _ q ( m y I n s t a n c e ) - 1 . 0 _ p R e a l ) 
 
                           ! *   S t r e s s   e x p o n e n t 
                           i f   ( g d o t _ s l i p = = 0 . 0 _ p R e a l )   t h e n 
                               c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + j )   =   0 . 0 _ p R e a l 
                           e l s e 
                               c o n s t i t u t i v e _ d i s l o t w i n _ p o s t R e s u l t s ( c + j )   =   ( t a u / g d o t _ s l i p ) * d g d o t _ d t a u s l i p 
                           e n d i f 
               e n d d o   ;   e n d d o 
               c   =   c   +   n s 
 
       e n d   s e l e c t 
 e n d d o 
 
 r e t u r n 
 e n d   f u n c t i o n 
 
 E N D   M O D U L E 
 