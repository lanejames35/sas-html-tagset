proc template;
   define tagset tagsets.ahtml;
      parent=tagsets.phtml;

      /*--- START OF PAGE HEAD ---*/

      define event doc;
         start:
            put "<!DOCTYPE html>" nl;
            put "<html lang=""en-us"">" nl;
            set $page_title body_title;
         finish:
            put "</html>";
      end;

      /* doc_head is inherited */

      define event doc_meta;
         put "<meta charset=""utf-8"">" nl;
			put "<meta content=""width=device-width,initial-scale=1"" name=""viewport"" >" nl;
      end;

      /* doc_title is inherited */
		/* Clear unnecessary events */
      define event javascript;
      end;
      define event startup_function;
      end;
      define event shutdown_function;
      end;

      /*--- END OF PAGE HEAD ---*/

      define event doc_body;
         put "<body>" nl;
         put "<main role=""main"">" nl;
         put "<h1 role=""heading"">" $page_title "</h1>" nl; 
         put "<section>" nl;

         finish:
            put "</main>" nl;
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
            put "<p>" $summary "</p>" nl;
         done;
      end;
      define event leaf;
      end;
      define event page_anchor;
      end;

      define event output;
         do /if cmp("Print",output_name);
            set $footnote clabel;
         done;
         do /if cmp("Report",output_name);
            set $footnote label;
         done;
         put "<div>" nl;
         finish:
            put "</div>" nl;
            unset $footnote;
      end;

      /***
		  Create WCAG 2.0 compliant tables
		*/
      define event table;
         eval $head_rows 1;
         set $table_num abs(1) /if not($table_num);
         putlog "*********** The value is" $table_num;
         start:
            put "<table>" nl;
            put "<caption>" $summary "</caption>" nl;
         finish:
            trigger system_footer;
            put "</table>" nl;
				/* Increment the table counter */
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

      define event row;
         eval $col_num 1;
         put "<tr>" nl;
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
         put "<img";
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
         put '<tfoot><tr><td';
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
