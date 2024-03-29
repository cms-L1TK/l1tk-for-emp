library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_misc.all;
  use ieee.numeric_std.all;

  use work.Constants.all;
  use work.BDTTypes.all;
  package Arrays0 is

    constant initPredict : ty := to_ty(0);
    constant feature : intArray2DnNodes(0 to nTrees - 1) := ((5, 2, 5, 5, 4, 4, 4, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 5, 5, 4, 4, 6, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 2, 4, 4, 6, 6, 5, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 6, 5, 4, 0, 2, 2, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 2, 4, 6, 4, 6, 2, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 4, 5, 6, 5, 4, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 4, 6, 6, 5, 5, 2, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 4, 3, 6, 2, 2, 6, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 4, 4, 6, 4, 6, 2, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 4, 0, 6, 3, 0, 1, -2, -2, -2, -2, -2, -2, -2, -2),
                (3, 5, 5, 2, 2, -2, 6, -2, -2, -2, -2, -2, -2, -2, -2),
                (3, 1, 5, 5, 0, -2, 6, -2, -2, -2, -2, -2, -2, -2, -2),
                (3, 4, 5, 0, 6, -2, 6, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 4, 6, 6, 1, 4, 2, -2, -2, -2, -2, -2, -2, -2, -2),
                (3, 6, 5, 4, 2, 6, 6, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 0, 1, 5, 4, 0, 5, -2, -2, -2, -2, -2, -2, -2, -2),
                (3, 1, 5, 1, 0, -2, 6, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 1, 1, 0, 0, 0, 1, -2, -2, -2, -2, -2, -2, -2, -2),
                (2, 5, 1, 4, 0, 0, 4, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 6, 1, 0, 1, 6, -2, -2, -2, -2, -2, -2, -2, -2, -2),
                (3, 0, 5, 0, 0, -2, 6, -2, -2, -2, -2, -2, -2, -2, -2),
                (6, 0, 0, 5, 0, 0, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (4, 5, 2, 1, 1, 1, 6, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 6, 0, 0, 1, -2, 1, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 4, 0, 1, 0, 2, 2, -2, -2, -2, -2, -2, -2, -2, -2),
                (3, 4, 5, 0, 1, 1, 1, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 1, 1, 1, 0, -2, 6, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 0, 0, 6, 6, 0, 2, -2, -2, -2, -2, -2, -2, -2, -2),
                (3, 0, 6, 0, 0, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2),
                (1, 2, 5, -2, 6, 4, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 0, 0, 5, 0, 2, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (4, 0, 6, 1, 0, 1, 2, -2, -2, -2, -2, -2, -2, -2, -2),
                (6, 1, 0, -2, 1, 5, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 6, 0, 1, 2, 0, 1, -2, -2, -2, -2, -2, -2, -2, -2),
                (1, 1, 1, 1, 2, 5, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 0, 1, 0, 1, 1, 6, -2, -2, -2, -2, -2, -2, -2, -2),
                (3, 4, 6, 2, 0, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 0, 6, 0, 4, 6, 1, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 0, 1, 4, 0, 1, 1, -2, -2, -2, -2, -2, -2, -2, -2),
                (1, 0, 0, -2, 6, 6, 6, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 0, 0, 1, -2, 1, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 0, 1, 0, 4, 1, 2, -2, -2, -2, -2, -2, -2, -2, -2),
                (3, 1, 6, 1, 1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 0, 0, 0, 0, 2, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (1, 2, 1, 1, 1, 1, 5, -2, -2, -2, -2, -2, -2, -2, -2),
                (1, 6, 6, 1, 1, -2, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (1, 1, 5, 1, 0, 2, 1, -2, -2, -2, -2, -2, -2, -2, -2),
                (4, 2, 1, 0, -2, 5, 1, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 5, 0, 1, 2, 5, 5, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 0, 0, 1, 1, -2, 5, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 6, 1, 4, 6, 1, 1, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 0, 4, 0, 6, 0, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (1, 2, 1, 1, 0, -2, 1, -2, -2, -2, -2, -2, -2, -2, -2),
                (5, 0, 1, 2, 0, 0, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (1, 1, 4, 6, 5, 0, 1, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 0, 0, 0, 0, 4, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (3, 0, 6, 2, 0, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 0, 5, 4, -2, 0, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (6, 1, 1, 2, 1, 2, 0, -2, -2, -2, -2, -2, -2, -2, -2),
                (0, 1, 0, 1, 1, -2, 0, -2, -2, -2, -2, -2, -2, -2, -2)
                );
    constant threshold_int : intArray2DnNodes(0 to nTrees - 1) := ((304, 144, 400, 272, 48, 48, 16, 0, 0, 0, 0, 0, 0, 0, 0),
                (336, 272, 464, 48, 48, 304, -54, 0, 0, 0, 0, 0, 0, 0, 0),
                (304, 144, 16, 48, 112, 272, 432, 0, 0, 0, 0, 0, 0, 0, 0),
                (272, 368, 432, 48, 32, 112, 144, 0, 0, 0, 0, 0, 0, 0, 0),
                (272, 144, 16, 368, 16, 144, 112, 0, 0, 0, 0, 0, 0, 0, 0),
                (336, 16, 464, 304, 112, 48, -54, 0, 0, 0, 0, 0, 0, 0, 0),
                (240, 48, 432, 304, 48, 464, 16, 0, 0, 0, 0, 0, 0, 0, 0),
                (208, 16, 144, 304, 112, 144, 208, 0, 0, 0, 0, 0, 0, 0, 0),
                (176, 48, 16, 304, 80, 208, 80, 0, 0, 0, 0, 0, 0, 0, 0),
                (336, 16, 57, 208, 144, -56, -11, 0, 0, 0, 0, 0, 0, 0, 0),
                (144, 112, 432, 80, 48, 0, 48, 0, 0, 0, 0, 0, 0, -64, -64),
                (144, 14, 432, 400, -22, 0, 48, 0, 0, 0, 0, 0, 0, -64, -64),
                (144, 48, 432, -58, 80, 0, 48, 0, 0, 0, 0, 0, 0, -64, -64),
                (112, 16, 432, 304, -13, 80, 48, 0, 0, 0, 0, 0, 0, 0, 0),
                (144, 144, 432, 16, 144, 16, 48, 0, 0, 0, 0, 0, 0, 0, 0),
                (56, 36, -11, 368, 16, 68, 464, 0, 0, 0, 0, 0, 0, 0, 0),
                (144, 11, 176, -11, -46, 0, 16, 0, 0, 0, 0, 0, 0, -64, -64),
                (464, 14, 13, 56, -15, -54, 17, 0, 0, 0, 0, 0, 0, 0, 0),
                (48, 208, -13, 16, -58, 28, 80, 0, 0, 0, 0, 0, 0, 0, 0),
                (67, 272, 9, -66, -14, 272, 0, 0, 0, 0, 0, 0, 0, -64, -64),
                (144, -37, 176, -49, -14, 0, 16, 0, 0, 0, 0, 0, 0, -64, -64),
                (144, 33, -40, 336, 46, -56, -12, 0, 0, 0, 0, 0, 0, 0, 0),
                (80, 464, 16, 9, 13, 4, 208, 0, 0, 0, 0, 0, 0, 0, 0),
                (67, 272, 70, -66, -14, 0, -8, 0, 0, 0, 0, 0, 0, -64, -64),
                (-32, 16, -25, 13, -49, 176, 16, 0, 0, 0, 0, 0, 0, 0, 0),
                (144, 80, 176, 46, -6, 5, 2, 0, 0, 0, 0, 0, 0, 0, 0),
                (464, 14, -19, -11, -11, 0, 432, 0, 0, 0, 0, 0, 0, -64, -64),
                (32, 19, 46, 208, 48, 42, 144, 0, 0, 0, 0, 0, 0, 0, 0),
                (176, -60, 16, -61, -37, 0, 0, 0, 0, 0, 0, -64, -64, -64, -64),
                (-21, 16, 464, 0, 400, 16, 54, 0, 0, 0, 0, 0, 0, -64, -64),
                (67, 38, 70, 432, 45, 16, 73, 0, 0, 0, 0, 0, 0, 0, 0),
                (80, -56, 48, 11, -37, 4, 80, 0, 0, 0, 0, 0, 0, 0, 0),
                (400, -21, 21, 0, -20, 208, 57, 0, 0, 0, 0, 0, 0, -64, -64),
                (48, 176, -69, -4, 48, -72, -17, 0, 0, 0, 0, 0, 0, 0, 0),
                (1, 1, 1, -1, 112, 368, 38, 0, 0, 0, 0, 0, 0, 0, 0),
                (56, 54, 4, 46, 0, 2, 368, 0, 0, 0, 0, 0, 0, 0, 0),
                (176, 80, 16, 208, 60, 0, 0, 0, 0, 0, 0, -64, -64, -64, -64),
                (67, 32, 272, 19, 16, 176, 8, 0, 0, 0, 0, 0, 0, 0, 0),
                (112, -18, -4, 16, 2, -5, -1, 0, 0, 0, 0, 0, 0, 0, 0),
                (19, -76, -22, 0, 208, 208, 432, 0, 0, 0, 0, 0, 0, -64, -64),
                (-51, -51, -37, 11, 0, 12, -36, 0, 0, 0, 0, 0, 0, -64, -64),
                (56, 54, 4, 46, 48, 2, 112, 0, 0, 0, 0, 0, 0, 0, 0),
                (176, 1, 16, 1, 2, 0, 0, 0, 0, 0, 0, -64, -64, -64, -64),
                (16, -43, 42, -71, -39, 144, 45, 0, 0, 0, 0, 0, 0, 0, 0),
                (-9, 176, -9, -13, -15, -9, 432, 0, 0, 0, 0, 0, 0, 0, 0),
                (21, 432, 208, 15, 6, 0, -23, 0, 0, 0, 0, 0, 0, -64, -64),
                (9, 9, 208, 8, -38, 112, 9, 0, 0, 0, 0, 0, 0, 0, 0),
                (80, 208, -6, -49, 0, 80, -5, 0, 0, 0, 0, 0, 0, -64, -64),
                (-32, 400, -25, -7, 144, 368, 400, 0, 0, 0, 0, 0, 0, 0, 0),
                (3, 2, 4, 7, -5, 0, 304, 0, 0, 0, 0, 0, 0, -64, -64),
                (112, 144, -4, 16, 432, -5, -4, 0, 0, 0, 0, 0, 0, 0, 0),
                (32, 17, 16, 12, 16, 33, 45, 0, 0, 0, 0, 0, 0, 0, 0),
                (-17, 16, -17, -20, 8, 0, -16, 0, 0, 0, 0, 0, 0, -64, -64),
                (464, -58, 10, 80, -58, -55, 12, 0, 0, 0, 0, 0, 0, 0, 0),
                (17, 16, 48, 48, 432, -48, 30, 0, 0, 0, 0, 0, 0, 0, 0),
                (3, -8, 12, -9, -8, 48, 14, 0, 0, 0, 0, 0, 0, 0, 0),
                (176, 42, 16, 144, 45, 0, 0, 0, 0, 0, 0, -64, -64, -64, -64),
                (-32, -32, 400, 16, 0, 2, 3, 0, 0, 0, 0, 0, 0, -64, -64),
                (272, -17, -4, 80, -17, 16, 33, 0, 0, 0, 0, 0, 0, 0, 0),
                (-49, -8, -48, -9, -8, 0, -48, 0, 0, 0, 0, 0, 0, -64, -64)
                );
    constant children_left : intArray2DnNodes(0 to nTrees - 1) := ((1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 13, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 13, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 13, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 13, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 13, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 13, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 13, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 13, 7, 9, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 13, 7, 9, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 13, 7, 9, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 13, 9, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 13, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 13, 9, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 13, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 13, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 13, 9, 11, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 11, 13, -1, -1, -1, -1, -1, -1, -1, -1),
                (1, 3, 5, 7, 9, 13, 11, -1, -1, -1, -1, -1, -1, -1, -1)
                );
    constant children_right : intArray2DnNodes(0 to nTrees - 1) := ((2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 14, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 14, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 14, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 14, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 14, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 14, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 14, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 14, 8, 10, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 14, 8, 10, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 14, 8, 10, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 14, 10, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 14, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 14, 10, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 14, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 14, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 14, 10, 12, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 12, 14, -1, -1, -1, -1, -1, -1, -1, -1),
                (2, 4, 6, 8, 10, 14, 12, -1, -1, -1, -1, -1, -1, -1, -1)
                );
    constant value_int : intArray2DnNodes(0 to nTrees - 1) := ((0, 0, 0, 0, 0, 0, 0, 18, 11, 11, -8, 2, -10, -7, -14),
                (0, 0, 0, 0, 0, 0, 0, 14, 9, 8, -3, -3, -12, -6, -12),
                (0, 0, 0, 0, 0, 0, 0, 12, 7, 7, -8, 3, -8, -5, -9),
                (0, 0, 0, 0, 0, 0, 0, 11, 6, -9, 7, 2, -6, -6, -11),
                (0, 0, 0, 0, 0, 0, 0, 9, -4, 8, -5, 5, -4, -4, -8),
                (0, 0, 0, 0, 0, 0, 0, 10, -2, 7, 0, 0, -6, 0, -7),
                (0, 0, 0, 0, 0, 0, 0, 9, -1, 5, -2, 0, -5, 0, -10),
                (0, 0, 0, 0, 0, 0, 0, 9, 0, 5, -5, -1, -6, 11, 5),
                (0, 0, 0, 0, 0, 0, 0, 8, -1, 2, -9, 4, -3, -1, -5),
                (0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 9, 4, -3, -8, 9),
                (0, 0, 0, 0, 0, 9, 0, 5, -1, 0, -3, 5, -2, 9, 9),
                (0, 0, 0, 0, 0, 9, 0, 2, -2, -12, -5, 4, -2, 9, 9),
                (0, 0, 0, 0, 0, 9, 0, 8, 0, -1, -5, 3, -2, 9, 9),
                (0, 0, 0, 0, 0, 0, 0, 7, -3, -14, 2, 0, -9, -1, -8),
                (0, 0, 0, 0, 0, 0, 0, 3, -1, -1, -7, 5, 8, 3, -2),
                (0, 0, 0, 0, 0, 0, 0, 2, -2, 3, -7, -8, 4, 9, -7),
                (0, 0, 0, 0, 0, 8, 0, -4, 0, -9, -3, -6, 6, 8, 8),
                (0, 0, 0, 0, 0, 0, 0, 0, 6, -10, -2, 2, -3, 17, -6),
                (0, 0, 0, 0, 0, 0, 0, 6, 1, 9, -1, -5, -12, -1, -9),
                (0, 0, 0, 0, 0, 0, -1, 8, 0, -8, -3, 5, 14, -1, -1),
                (0, 0, 0, 0, 0, 8, 0, 1, -7, 2, -1, -5, 4, 8, 8),
                (0, 0, 0, 0, 0, 0, 0, 2, -1, -7, 2, -1, -10, 1, -2),
                (0, 0, 0, 0, 0, 0, 0, 0, -3, -2, 4, 3, -6, -9, 2),
                (0, 0, 0, 0, 0, 10, 0, 6, 0, -7, -2, -4, 5, 10, 10),
                (0, 0, 0, 0, 0, 0, 0, 3, -9, 0, -7, 3, 15, 1, -1),
                (0, 0, 0, 0, 0, 0, 0, -1, 2, -9, -2, 8, 3, -3, 5),
                (0, 0, 0, 0, 0, 9, 0, -2, 0, -7, -1, -2, -8, 9, 9),
                (0, 0, 0, 0, 0, 0, 0, 0, -3, 6, 1, -2, -12, 3, -6),
                (0, 0, 0, 0, 0, -3, 8, 1, 12, -3, 0, -3, -3, 8, 8),
                (0, 0, 0, 8, 0, 0, 0, -11, -4, 1, -1, -1, -7, 8, 8),
                (0, 0, 0, 0, 0, 0, 0, 0, -1, -6, 0, 2, 9, -1, 6),
                (0, 0, 0, 0, 0, 0, 0, 3, -6, -3, 0, -3, -15, 3, -5),
                (0, 0, 0, -10, 0, 0, 0, 9, 0, -10, -2, 5, -3, -10, -10),
                (0, 0, 0, 0, 0, 0, 0, -1, 4, 0, -8, 0, 10, -5, -1),
                (0, 0, 0, 0, 0, 0, 0, -1, 2, 5, 14, -14, -2, -1, -3),
                (0, 0, 0, 0, 0, 0, 0, -1, 2, -6, -15, 2, -11, 9, -4),
                (0, 0, 0, 0, 0, -2, 8, 0, -9, -4, 4, -2, -2, 8, 8),
                (0, 0, 0, 0, 0, 0, 0, -1, 2, 2, -3, 4, -5, 8, -1),
                (0, 0, 0, 0, 0, 0, 0, 3, -3, 6, 1, 0, 7, -3, -1),
                (0, 0, 0, 8, 0, 0, 0, 0, -1, -4, 7, -9, -3, 8, 8),
                (0, 0, 0, 0, 12, 0, 0, 1, -6, -4, 5, 9, 0, 12, 12),
                (0, 0, 0, 0, 0, 0, 0, -1, 2, -12, -1, 1, -8, 8, -2),
                (0, 0, 0, 0, 0, -2, 7, 0, 5, -4, -1, -2, -2, 7, 7),
                (0, 0, 0, 0, 0, 0, 0, -7, 5, -10, 0, -1, 1, -8, 0),
                (0, 0, 0, 0, 0, 0, 0, 1, -2, -9, -2, -1, 15, 0, -1),
                (0, 0, 0, 0, 0, -10, 0, 0, 3, -4, 3, 4, -4, -10, -10),
                (0, 0, 0, 0, 0, 0, 0, 0, -3, -8, 8, -2, -13, -11, 0),
                (0, 0, 0, 0, -7, 0, 0, 1, -1, 3, -10, 9, -3, -7, -7),
                (0, 0, 0, 0, 0, 0, 0, -6, -1, 2, -5, 6, 1, 0, -1),
                (0, 0, 0, 0, 0, 11, 0, 0, -2, -1, -10, -1, 0, 11, 11),
                (0, 0, 0, 0, 0, 0, 0, 4, 0, -3, 3, 0, 5, -10, -1),
                (0, 0, 0, 0, 0, 0, 0, 0, -3, 5, 0, -9, 3, -4, -1),
                (0, 0, 0, 0, 0, 11, 0, 13, -2, -2, -9, -7, 0, 11, 11),
                (0, 0, 0, 0, 0, 0, 0, 3, -2, -12, 0, -7, -1, 7, -4),
                (0, 0, 0, 0, 0, 0, 0, 0, -1, 9, -3, 11, -2, -9, 0),
                (0, 0, 0, 0, 0, 0, 0, -1, 7, -14, -2, 0, 6, -4, 0),
                (0, 0, 0, 0, 0, -3, 7, -1, 2, -6, 0, -3, -3, 7, 7),
                (0, 0, 0, 0, -17, 0, 0, 1, -2, 2, -1, -2, 0, -17, -17),
                (0, 0, 0, 0, 0, 0, 0, 0, -9, 10, 0, 4, -2, -3, 3),
                (0, 0, 0, 0, 0, -12, 0, -2, -14, 17, 1, 9, -1, -12, -12)
                );
    constant parent : intArray2DnNodes(0 to nTrees - 1) := ((-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 6, 6, 5, 5),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 6, 6, 5, 5),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 6, 6, 5, 5),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 6, 6, 5, 5),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 6, 6, 5, 5),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 6, 6, 5, 5),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 6, 6, 5, 5),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 4, 4, 5, 5, 6, 6, 3, 3),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 4, 4, 5, 5, 6, 6, 3, 3),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 4, 4, 5, 5, 6, 6, 3, 3),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 5, 5, 6, 6, 4, 4),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 6, 6, 5, 5),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 5, 5, 6, 6, 4, 4),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 6, 6, 5, 5),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 6, 6, 5, 5),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 5, 5, 6, 6, 4, 4),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6),
                (-1, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 6, 6, 5, 5)
                );
    constant depth : intArray2DnNodes(0 to nTrees - 1) := ((0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3),
                (0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3)
                );
    constant iLeaf : intArray2DnLeaves(0 to nTrees - 1) := ((7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14),
                (7, 8, 9, 10, 11, 12, 13, 14)
                );
    constant value : tyArray2DnNodes(0 to nTrees - 1) := to_tyArray2D(value_int);
      constant threshold : txArray2DnNodes(0 to nTrees - 1) := to_txArray2D(threshold_int);
end Arrays0;