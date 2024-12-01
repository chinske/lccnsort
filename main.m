% LCCNSORT Library of Congress Call Number Sort

ifile = 'librarything_chinskec.xls';
ofile = 'librarything_chinskec_sorted.xls';

library = import_file(ifile);
library = sort_by_lccn(library);
writetable(library,ofile);