library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

package hybrid_tools is

type integers   is array ( natural range <> ) of integer;
type naturals   is array ( natural range <> ) of natural;
type booleans   is array ( natural range <> ) of boolean;
type std_logics is array ( natural range <> ) of std_logic;
type reals      is array ( natural range <> ) of real;

constant widthDoubleExp: natural := 11;
constant widthDoubleMan: natural := 52;
constant widthDouble:    natural := 1 + widthDoubleExp + widthDoubleMan;

constant baseDoubleMan: real    := 2.0 ** widthDoubleMan - 1.0;
constant biasDoubleExp: natural := 2 ** ( widthDoubleExp - 1 ) - 1;

function to_string( std: std_logic_vector ) return string;

function uint ( s: std_logic_vector ) return integer;
function sint ( s: std_logic_vector ) return integer;
function int ( val, base: real ) return integer;

function incr ( s: std_logic_vector ) return std_logic_vector;
function decr ( s: std_logic_vector ) return std_logic_vector;

function msb( x: std_logic_vector ) return std_logic;
function msb( x: signed           ) return std_logic;
function msb( x: unsigned         ) return std_logic;

function max( a, b: real     ) return real;
function min( a, b: real     ) return real;
function max( a, b: integer  ) return integer;
function min( a, b: integer  ) return integer;

function stds ( x, w: integer ) return std_logic_vector;
function stdu ( x, w: integer ) return std_logic_vector;
function std ( x: integer ) return std_logic;

function stds ( x: real; w: natural ) return std_logic_vector;
function stdu ( x: real; w: natural ) return std_logic_vector;

function ureal( s: std_logic_vector ) return real;
function sreal( s: std_logic_vector ) return real;
function ureal( s: std_logic_vector; high, low: natural ) return real;
function sreal( s: std_logic_vector; high, low: natural ) return real;
function dreal( s: std_logic_vector ) return real;

function confine( val, limit: real ) return real;
function confine( val, limit: integer ) return integer;

function width( x: integer ) return integer;
function width( x: real    ) return integer;

function max( v: reals    ) return real;
function max( v: naturals ) return natural;
function sum( v: naturals ) return natural;
function sum( v: naturals; low, high: natural ) return natural;
function nota( w, v: natural ) return naturals;

function isElement( x: natural; v: naturals ) return boolean;

function "abs" ( x: std_logic_vector ) return std_logic_vector;
function  sba  ( x: std_logic_vector ) return std_logic_vector;

function overflowed ( x: unsigned; w:integer ) return boolean ;
function overflowed ( x: signed;   w:integer ) return boolean ;

function interleave ( l, r: unsigned ) return unsigned;
function interleave ( l, r: signed   ) return signed  ;

function decode( s: std_logic_vector; w: integer ) return std_logic_vector;
function encode( s: std_logic_vector ) return std_logic_vector;
function count( v: std_logic_vector; s: std_logic ) return natural;
function count( v: std_logic_vector; high, low: natural; s: std_logic ) return natural;

function resize( s: std_logic_vector; n: natural ) return std_logic_vector;

function "*" ( l, r: std_logic_vector ) return std_logic_vector;
function "+" ( l, r: std_logic_vector ) return std_logic_vector;
function "-" ( l, r: std_logic_vector ) return std_logic_vector;

function rangeLimit( ranges: reals ) return reals;

function usr( s: std_logic_vector; n: natural ) return std_logic_vector;
function usl( s: std_logic_vector; n: natural ) return std_logic_vector;
function ssr( s: std_logic_vector; n: natural ) return std_logic_vector;
function ssl( s: std_logic_vector; n: natural ) return std_logic_vector;

end;



package body hybrid_tools is



function to_string( std: std_logic_vector ) return string is
  variable s: string( std'range ) := ( others => NUL );
begin
  for i in std'range loop s( i ) := std_logic'image( std( i ) )( 2 ); end loop; return s;
end function;

function uint( s: std_logic_vector ) return integer is begin return to_integer( unsigned( s ) ); end function;
function sint( s: std_logic_vector ) return integer is begin return to_integer( signed( s ) ); end function;

function int ( val, base: real ) return integer is begin return integer( floor( val / base ) ); end function;

function incr( s: std_logic_vector ) return std_logic_vector is begin return std_logic_vector( unsigned( s ) + 1 ); end function;
function decr( s: std_logic_vector ) return std_logic_vector is begin return std_logic_vector( unsigned( s ) - 1 ); end function;

function msb( x: std_logic_vector ) return std_logic is begin return x( x'high ); end function;
function msb( x: signed           ) return std_logic is begin return x( x'high ); end function;
function msb( x: unsigned         ) return std_logic is begin return x( x'high ); end function;

function max( a, b: real ) return real is begin if b > a then return b; end if; return a; end function;
function min( a, b: real ) return real is begin if b < a then return b; end if; return a; end function;
function max( a, b: integer ) return integer is begin if b > a then return b; end if; return a; end function; 
function min( a, b: integer ) return integer is begin if b < a then return b; end if; return a; end function;

function stds ( x, w: integer ) return std_logic_vector is begin return std_logic_vector( to_signed( x, w ) ); end function;
function stdu ( x, w: integer ) return std_logic_vector is begin return std_logic_vector( to_unsigned( x, w ) ); end function;
function std ( x: integer ) return std_logic is begin if x = 0 then return '0'; end if; return '1'; end function;

function stds ( x: real; w: natural ) return std_logic_vector is
begin
    if abs( x ) > 2.0 ** 31 - 1.0 and w > 31 then
        return stds( x / 2.0 ** 31, w - 31 ) & stdu( floor( x - floor( x / 2.0 ** 31 ) * 2.0 ** 31 ), 31 );
    end if;
    return stds( integer( floor( x ) ), w );
end function;

function stdu ( x: real; w: natural ) return std_logic_vector is
begin
    if abs( x ) > 2.0 ** 31 - 1.0 and w > 31 then
        return stdu( x / 2.0 ** 31, w - 31 ) & stdu( floor( x - floor( x / 2.0 ** 31 ) * 2.0 ** 31 ), 31 );
    end if;
    return stdu( integer( floor( x ) ), w );
end function;

function ureal( s: std_logic_vector ) return real is begin return ureal( s, s'high, s'low ); end function;
function sreal( s: std_logic_vector ) return real is begin return ureal( s, s'high, s'low ); end function;

function ureal( s: std_logic_vector; high, low: natural ) return real is
    variable len: natural := high - low + 1;
begin
    if len > 31 then
        return ureal( s, high, low + 31 ) * 2.0 ** 31 + real( uint( s( low + 31 - 1 downto  low ) ) );
    end if;
    return real( uint( s( high downto low ) ) );
end function;

function sreal( s: std_logic_vector; high, low: natural ) return real is
    variable len: natural := high - low + 1;
begin
    if len > 31 then
        return sreal( s, high, low + 31 ) * 2.0 ** 31 + real( sint( s( low + 31 - 1 downto  low ) ) );
    end if;
    return real( sint( s( high downto low ) ) );
end function;

function dreal( s: std_logic_vector ) return real is
    variable man: real;
    variable exp: integer;
begin
    man := ureal( s( widthDoubleMan - 1 downto  0 ) );
    exp := uint( s( widthDoubleExp + widthDoubleMan - 1 downto widthDoubleMan ) );
    man := 1.0 + man / baseDoubleMan;
    exp :=  exp - biasDoubleExp;
    if msb( s ) = '1' then
        man := -1.0 * man;
    end if;
    return man * 2.0 ** exp;
end function;

function confine( val, limit: real ) return real is
    variable v: real := abs( val );
    variable s: real := sign( val );
begin
    return s * min( v, limit );
end function;

function confine( val, limit: integer ) return integer is
begin
    if val < -limit then
        return - limit;
    elsif val > limit - 1 then
        return limit - 1;
    end if;
    return val;
end function;

function width( x: integer ) return integer is begin return width( real( x ) ); end function;

function width( x: real ) return integer is
    variable y: real := abs( x );
begin
    if y < 1.0 and y > 0.0 then
        return 1;
    end if;
    if y = 0.0 then
        return 0;
    end if;
    return integer( ceil( log2( y ) ) );
end function;

function max( v: reals ) return real is
    variable m: real := v( v'low );
begin
    for k in v'range loop
        m := max( m, v( k ) );
    end loop;
    return m;
end function;

function max( v: naturals ) return natural is
    variable res: natural := v( v'high );
begin
    for k in v'range loop
        res := max( res, v( k ) );
    end loop;
    return res;
end function;

function sum( v: naturals ) return natural is begin return sum( v, v'low, v'high ); end function;

function sum( v: naturals; low, high: natural ) return natural is
    variable s: natural := 0;
begin
    for k in low to high loop
        s := s + v( k );
    end loop;
    return s;
end function;

function nota( w, v: natural ) return naturals is
  variable n: naturals( 0 to w - 1 );
begin
  for k in n'range loop
    n( k ) := v + k;
  end loop;
  return n;
end function;

function isElement( x: natural; v: naturals ) return boolean is
begin
    for k in v'range loop
        if x = v( k ) then
            return true;
        end if; 
    end loop;
    return false;
end;

function "abs" ( x: std_logic_vector ) return std_logic_vector is
    variable y: std_logic_vector( x'range );
begin
    y := x;
    if x( x'high ) = '1' then
        y := not x;
    end if;
    return y( y'high - 1 downto y'low );
end function;

function sba( x: std_logic_vector ) return std_logic_vector is begin return not msb( x ) & x( x'high - 1 downto x'low ); end function;

function overflowed( x: unsigned; w: integer ) return boolean is
begin
    if x'length < w then
        return false;
    end if;
    return unsigned( x( x'high downto x'low + w ) ) > 0;
end function;

function overflowed( x: signed; w: integer ) return boolean is
begin
    if x'length < w - 1 then
        return false;
    end if;
    return signed( x( x'high downto x'low + w - 1 ) ) /= 0 and signed( x( x'high downto x'low + w - 1 ) ) /= -1;
end function;
 
function interleave ( l, r: unsigned ) return unsigned is begin return l( l'high - l'length + r'length downto l'low ); end function;
function interleave ( l, r: signed ) return signed is begin return l( l'high - l'length + r'length downto l'low ); end function;

function decode( s: std_logic_vector; w: integer ) return std_logic_vector is begin return std_logic_vector( to_unsigned( 2 ** to_integer( unsigned( s ) ), w ) ); end function;

function encode( s: std_logic_vector ) return std_logic_vector is
    variable len: natural := width( s'length );
    variable l: natural := 0;
begin
    for k in s'range loop
        if s( k ) = '1' then
            l := k;
        end if;
    end loop;
    return stdu( l, len );
end function;

function count( v: std_logic_vector; s: std_logic ) return natural is
    variable i: natural := 0;
begin
    for k in v'range loop
        if v( k ) = s then
            i := i + 1;
        end if;
    end loop;
    return i;
end function;


function count( v: std_logic_vector; high, low: natural; s: std_logic ) return natural is
    variable i: natural := 0;
begin
    if low > high then
        return 0;
    end if;
    for k in v'range loop
        if k >= low and k <= high and v( k ) = s then
            i := i + 1;
        end if;
    end loop;
    return i;
end function;

function resize( s: std_logic_vector; n: natural ) return std_logic_vector is begin return std_logic_vector( resize( signed( s ), n ) ); end function;

function "*" ( l, r: std_logic_vector ) return std_logic_vector is begin return std_logic_vector( signed( l ) * signed( r ) ); end function;

function "+" ( l, r: std_logic_vector ) return std_logic_vector is
    variable len: natural := max( l'length, r'length ) + 1;
begin
    return std_logic_vector( resize( signed( l ), len ) + resize( signed( r ), len ) );
end;

function "-" ( l, r: std_logic_vector ) return std_logic_vector is
    variable len: natural := max( l'length, r'length ) + 1;
begin
    return std_logic_vector( resize( signed( l ), len ) - resize( signed( r ), len ) );
end;

function rangeLimit( ranges: reals ) return reals is
    variable len: natural := ranges'length;
    variable res: reals( len / 2 - 2 downto 0 );
begin
    for k in len / 2 - 2 downto 0 loop
        res( k ) := ( ranges( 2 * ( k + 1 ) ) + ranges( 2 * ( k + 1 ) - 1 ) ) / 2.0;
    end loop;
    return res;
end function;

function usr( s: std_logic_vector; n: natural ) return std_logic_vector is begin return std_logic_vector( shift_right( unsigned( s ), n ) ); end function;

function usl( s: std_logic_vector; n: natural ) return std_logic_vector is begin return std_logic_vector( shift_left( unsigned( s ), n ) ); end function;
--function usl( s: std_logic_vector; n: natural ) return std_logic_vector is
--    variable res: std_logic_vector( s'high + 1 downto s'low ) := s & '1';
--begin
--    res := std_logic_vector( shift_left( unsigned( res ), n ) );
--    return res( res'high downto res'low + 1 );
--end function;

function ssr( s: std_logic_vector; n: natural ) return std_logic_vector is begin return std_logic_vector( shift_right( signed( s ), n ) ); end function;

function ssl( s: std_logic_vector; n: natural ) return std_logic_vector is begin return std_logic_vector( shift_left( signed( s ), n ) ); end function;

end;