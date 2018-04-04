proc template;
   define tagset tagsets.ahtml;
      parent=tagsets.phtml;

      /*--- START OF PAGE HEAD ---*/

      define event doc;
         start:
            put "<!DOCTYPE html>" nl;
            put "<!--[if lt IE 9]><html class=""no-js lt-ie9"" lang=""en-us""><![endif]-->" nl;
            put "<!--[if gt IE 8]><!--><html lang=""en-us""><!--<![endif]-->" nl;
            set $page_title body_title;
         finish:
            put "</html>";
      end;

      /* doc_head is inherited */

      define event doc_meta;
         put "<!-- Web Experience Toolkit (WET) / Boite d'outils de l'experience Web (BOEW) wet-boew.github.io/wet-boew/License-en.htm / wet-boew.github.io/wet-boew/Licence-fr.htm -->";
         put "<meta charset=""utf-8"">" nl;
         put "<!--[if lt IE 9]>" nl;
         put "<link rel=""stylesheet"" href=""./wet-boew-dist-4.0.22/css/ie8-wet-boew.min.css"">" nl;
         put "<script src=""https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js""></script>" nl;
         put "<script src=""./wet-boew-dist-4.0.24/js/ie8-wet-boew.min.js""></script>" nl;
         put "<script src=""./wet-boew-dist-4.0.24/js/details.min.js""></script>" nl;
         put "<![endif]-->" nl;
         put "<noscript><link rel=""stylesheet"" href=""./wet-boew-dist-4.0.24/css/noscript.min.css""></noscript>" nl;
      end;

      /* doc_title is inherited */

      define event javascript;
      end;
      define event startup_function;
      end;
      define event shutdown_function;
      end;

      /*--- END OF PAGE HEAD ---*/

      define event doc_body;
         put "<body>" nl;
         put "<main class=""container"" role=""main"">" nl;
         put "<div class=""row"">" nl;
         put "<h1 class=""wb-inv"" role=""heading"" property=""name"">Welcome to health statistics in Durham Region</h1>" nl; 
         put "</div>" nl;
         put "<section>" nl;
         put "<div class=""row"">" nl;
         put "<div class=""col-md-12"">" nl;
         put "<h2 class=""h1 page-header"">" $page_title "</h2>" nl;
         put "</div></div>" nl;

         finish:
            /* End the section with a closing tag after On This Page */
            put "</main>" nl;
            put "<!--[if gte IE 9 | !IE ]><!-->" nl;
            put "<script src=""https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js""></script>" nl;
            put "<script src=""./wet-boew-dist-4.0.24/js/wet-boew.min.js""></script>" nl;
            put "<script src=""./wet-boew-dist-4.0.24/js/theme.min.js""></script>" nl;
            put "<script src=""./wet-boew-dist-4.0.24/js/polyfills/jawsariafixes.js""></script>" nl;
            put "<!--<![endif]-->" nl;
            put "<!--[if lt IE 9]>" nl;
            put "<script src=""./wet-boew-dist-4.0.24/js/ie8-wet-boew2.min.js""></script>" nl;
            put "<![endif]-->" nl;
            put "</body>" nl;
      end;

      /*--- START PROCEDURE OUTPUT ---*/
      define event proc;
      end;
      define event anchor;
      end;
      define event proc_branch;   
         set $summary value;
         do /if ^cmp("Print",name);
            put "<p";
            put " class=""h4""";
            put ">";
            put $summary;
            put "</p>" nl;
         done;
      end;
      define event leaf;
      end;
      define event page_anchor;
      end;

      define event output;
         do /if cmp("Print",output_name);
            set $footnote clabel;
            set $class 'table';
         done;
         do /if cmp("Report",output_name);
            set $footnote label;
            set $class 'table';
         done;
         put '<div';
         put ' class="table-responsive"' /if cmp("table",$class);
         put '>' nl;
         finish:
            put "</div>" nl;
            unset $footnote;
            unset $class;
      end;

      /* ###    TABLES #### */
      define event table;
         eval $head_rows 1;
			set $table_num abs(1) /if not($table_num);
			putlog "*********** The value is" $table_num;
         start:
            put "<table";
            put " class=""pub-table"">" nl;
            put "<caption class=""wb-inv"">";
            put $summary;
            put "</caption>" nl;
         finish:
            trigger system_footer;
            put "</table>" nl;
				set $table_num sum($table_num,1);
				putlog "************** now the value is" $table_num;
      end;
      /* Grab number of columns for footnote span amount */
      define event colspecs;
         eval $cols 0;
      end;
      define event colspec_entry;
         eval $cols $cols+1;
         put "<col>" nl;
      end;
      /* Ensure proper heading span */
      define event table_head;
         put '<thead>' nl;
         finish:
            put '</thead>' nl;
      end;

      /* Highlight table rows */
      define event row;
         eval $col_num 1;
         put "<tr";
         put ' class="highlight-row"' /if cmp("body",section);
         put ">" nl;
         finish:
            put "</tr>" nl;
            unset $col_num;
            unset $row_header;
            do /if cmp("head",section);
               eval $head_rows $head_rows+1;
            done;
      end;

      /* Table header cells with IDs */
      define event header;
         set $col col_id;
         set $row row;
         /* IDs for tables from PROC REPORT */
         do /if cmp("Report",output_name);
            set $row_id cat("r_",row);
            set $col_id cat("_c_",$col_num);
            set $id cat($row_id,$col_id);
         done;

         /* skip this step for empty header cells */
         do /if ^exists(value);
            set $row_id "r_1";
            set $id cat($row_id,$col_id);
            set $headList[] $id;
            eval $col_num $col_num+1;
            break;
         done;

         put "<th";

	       /* Cell IDs for accessibility tags */
			put ' scope="col"';
         put ' id="';
			put "t" $table_num "-";
         put "h_" /if cmp("Print",output_name);
         put $col /if cmp("Print",output_name);
         put $row_id /if cmp("Report",output_name);
         put $col_id /if cmp("Report",output_name);
			put '"';

         /* Header association for multi-row headings */
         do /if cmp("Report",output_name);
            set $headList[] $id;
            putlog $headList[$col_num];
               do /if ^cmp("1",row);
                  put ' headers="';
						put "t" $table_num "-";
                  put $headList[$col_num];
						put '"';
               done;
            eval $col_num $col_num+1;
         done;

         /* Text alignment within cells */
         put ' class="';
         put 'row-heading"' /if cmp("head",section);
         put 'row-stub"' /if cmp("body",section);

         /* Spanning headers */
         do /if exists(colspan);
            put " colspan=";
            putq colspan;
         done;

         /* Close up the tag and print the value */
         put ">";
         put value;
         put "</th>" nl;
      end;

      /* Empty cell event */
      define event cell_is_empty;
      end;

      /* iterate the column counter */
      define event colspanfillsep;
         eval $col_num $col_num+1;
         set $headList[] $id;
         putlog $headList[$col_num];
      end;

      /* Table data cells with header associations */
      define event table_body;
         eval $col_num 0;
         start:
            put "<tbody>" nl;
         finish:
            put "</tbody>" nl;
      end;
      
      define event data;
         set $this_col $col_num;
         set $myOutput output_name;
         do /if cmp("Report",output_name);
            trigger data_first /if cmp("1",$this_col);
            break /if cmp("1",$this_col);
         done;

         eval $cell $col_num+$cols;
         put "<td";
         /* Header associations */
         put ' headers="';
			put "t" $table_num "-";
         put "h_" /if cmp("Print",output_name);
         put $this_col /if cmp("Print",output_name);
         put $row_header " " /if cmp("Report",output_name);

         /* Header association for multi-row headings */
         do /if cmp("Report",output_name);
            eval $count 1;
            do /while $count < $head_rows;
               putlog "Column" $cell;
					put "t" $table_num "-";
               put $headList[$cell];
               put " " /if $count le $head_rows;
               eval $cell $cell-$cols;
               eval $count $count+1;
            done;
         done;
         put '"';
         put ">";
         put value;
         put "</td>" nl;
         unset $this_col;
         unset $myOutput;
         eval $col_num $col_num+1;
      end;
      define event data_first;
         put "<th";
         /* Cell IDs for accessibility tags */
         put ' id="';
			put "t" $table_num "-";
         set $row_id cat("r_",row);
         set $col_id cat("_c_",$col_num);
         put $row_id /if cmp("Report",output_name);
         put $col_id /if cmp("Report",output_name);
         set $row_header cat($row_id,$col_id);
         put '"';
         put ' headers="';
			put "t" $table_num "-";
         put $headList[$col_num] '"';
			put ' scope="row"';
         /* Left align style tag */
         put ' class="row-stub"';
         put ">";
         put value;
         put "</th>" nl;
         eval $col_num $col_num+1;
      end;

      /*--- END PROCEDURE OUTPUT ---*/

      /*--- USER TEXT ---*/
      define event text_group;
      end;

      define event text_row;
      end;

      define event text;
         putl value;
      end;
      /*--- END USER TEXT ---*/

      /*--- IMAGES (i.e. GRAPHS) ---*/
      define event image;
         /* Display image in a dialog box */
         put "<img";
         put " class=""img-responsive""";
         putq " title=" title;
         putq " alt=" alt;
         put " src=""";
         put basename / if ^exists(nobase);
         put URL;
         put """>" nl;
      end;

      /* Footnotes */
      define event system_footer_setup;
      end;
      define event system_footer_group;
      end;
      define event footer_container;
      end;
      define event footer_container_spec;
      end;
      define event footer_container_specs;
      end;
      define event footer_container_row;
      end;
      define event system_footer_setup;
      end;

      define event system_footer;
         put '<tfoot><tr><td class="table-footer"';
			put ' headers="t' $table_num "-";
			put 'h1"'/if cmp("Print",output_name);
			put 'r_1_c_1"' /if cmp("Report",output_name);
         put " colspan=";
         putq $cols;
         put ">";
         put $footnote;
         put "</td></tr></tfoot>" nl;
      end;

         define event stylesheet_link;
            break /if ^exists( url);
            set $urlList url;
            eval $colon index(stylesheet_url,":");
            do /if 0 < $colon < 7;
               set $firstword scan(stylesheet_url,1,":");

            do /if cmp( $firstword, "http");
               set $urlList stylesheet_url;

            else /if cmp( $firstword, "https");
                 set $urlList stylesheet_url;

            else /if cmp( $firstword, "file");
               set $urlList stylesheet_url;
               done;
            done;
            trigger urlLoop;
            unset $urlList;
         end;
   end;
run;
