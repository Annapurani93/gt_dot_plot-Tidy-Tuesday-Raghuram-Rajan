library(tidytuesdayR)
library(tidyverse)
library(gtExtras)
library(gtable)
library(gt)
library(gtsummary)
library(dplyr)
tuesdata <- tidytuesdayR::tt_load(2021, week = 40)
papers <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-09-28/papers.csv')
authors <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-09-28/authors.csv')
programs <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-09-28/programs.csv')
paper_authors <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-09-28/paper_authors.csv')
paper_programs <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-09-28/paper_programs.csv')


papers%>%left_join(paper_authors)%>%left_join(authors)%>%
  left_join(paper_programs)%>%
  left_join(programs)%>%drop_na()->paper1

paper1%>%select(paper,year,title,name,program_desc)%>%
  filter(str_detect(name,"Raghu"))%>%
  distinct(title,.keep_all = TRUE)%>%
  select(year,title,program_desc)%>%
  group_by(year,program_desc)%>%
  count()%>%
  pivot_wider(names_from = program_desc,values_from = n)%>%
  mutate(across(everything(), .fns = ~replace_na(.,0))) ->paper2

data.frame(paper2)->paper2
paper2%>%rowwise()%>%mutate(Total=sum(c_across(Corporate.Finance:Asset.Pricing)))->paper2

source_tag <- "Data: <a href='https://www.nber.org/'>NBER</a> via TidyTuesday| Design and Analysis: @annapurani93"

colnames(paper2)<-c("YEAR","CORPORATE FINANCE","INTERNATIONAL FINANCE",
                    "ECONOMIC GROWTH","ASSET PRICING","TOTAL")
paper2%>%
  gt()%>%
  gt_plt_dot(TOTAL, YEAR, palette = c("#d1dd93")) %>%
  cols_width(YEAR ~ px(100))%>%
  gt_color_box(columns = `CORPORATE FINANCE`, domain = 0:5,  palette = c("#ff8c8c","#f0edaa","#d1dd93"))%>%
  gt_color_box(columns = `ASSET PRICING`, domain = 0:5,  palette = c("#ff8c8c","#f0edaa", "#d1dd93"))%>%
  gt_color_box(columns = `ECONOMIC GROWTH`, domain = 0:5,  palette = c("#ff8c8c","#f0edaa", "#d1dd93"))%>%
  gt_color_box(columns = `INTERNATIONAL FINANCE`, domain = 0:5,  palette = c("#ff8c8c","#f0edaa", "#d1dd93"))%>%
  tab_options(
  table.background.color = "#051e3e")%>%
  tab_header(
    title = md("**Raghuram Rajan's Working Papers at the National Bureau of Economic Research**"),
    subtitle = "Indian economist Raghuram Rajan has published 55 papers in total at the NBER, so far, on different subjects - he has published 47 papers in Corporate Finance, 4 in International Finance and Macroeconomics, 2 each in Asset Pricing and Economic Fluctuations and Growth. 
    
    His latest paper with fellow economists Douglas Diamond and Yunzhi Hu is titled 'Liquidity, Pledgeability, and the Nature of Lending', which discusses how corporate lending and financial intermediation change based on the fundamentals of the firm and its environment"
  )%>%
  tab_source_note(md(html(source_tag)))%>%
  tab_style(
    style = list(
      cell_text(
        align = "right",
        color = "white"
      )
    ),
    locations = cells_source_notes()
  )%>%
  cols_align(
    align = "center",
    columns = c(YEAR,`CORPORATE FINANCE`,`ASSET PRICING`,
                `INTERNATIONAL FINANCE`,`ECONOMIC GROWTH`,TOTAL))%>% 
  tab_style(style = cell_text(weight="bold"),
            locations = cells_column_labels(everything())
  )%>%
  tab_style(
    style = cell_text(align="center"),
    locations = cells_body(
      columns = everything(),
      rows = everything()
    )
  )%>%
  opt_table_lines("all")%>%
  opt_table_outline()%>%
  opt_row_striping()%>%
  tab_options(
    source_notes.background.color = "#051e3e",
    heading.background.color = "#051e3e",
    column_labels.background.color = "#d1dd93",
    table_body.hlines.color = "#989898",
    table_body.border.top.color = "#989898",
    heading.border.bottom.color = "#989898",
    row_group.border.top.color = "#989898"
  )%>%
  tab_style(
    style = list(
      cell_borders(
        sides = c("top", "bottom"),
        color = "black",
        weight = px(0.2),
        style="dotted"
      ),
      cell_borders(
        sides = c("left", "right"),
        color = "black",
        weight = px(0.2),
        style="dotted"
      )),
    locations = cells_column_labels(
      columns = everything()
    )
  )%>%
  tab_style(
    style = list(
      cell_borders(
        sides = c("top", "bottom"),
        color = "#989898",
        weight = px(1),
        style="dashed"
      ),
      cell_borders(
        sides = c("left", "right"),
        color = "#989898",
        weight = px(1),
        style="dashed"
      )),
    locations = cells_body(
      columns = everything(),
      rows = everything()
    )
  )%>%
  tab_style(
    style = list(
      cell_text(
        color = "white",
        transform = "uppercase"
      )
    ),
    locations = list(
      cells_title(groups = "title")
    )
  ) %>%
  # Adjust sub-title font
  tab_style(
    style = list(
      cell_text(
        color="white"
      )
    ),
    locations = list(
      cells_title(groups = "subtitle")
    )
  )%>%
  tab_style(
    style = cell_text(weight = "bold", align="center",color = "#d1dd93"),
    locations = cells_body(
      columns = TOTAL,
      rows = everything()
    )
  )%>%
  cols_width(
    everything() ~ px(140)
  )%>%
  tab_footnote(
    footnote = "International finance and macroeconomics",
    locations = cells_column_labels(columns = `INTERNATIONAL FINANCE`)
  )%>%
  tab_footnote(
    footnote = "Economic fluctutation and growth",
    locations =  cells_column_labels(columns = `ECONOMIC GROWTH`)
  )->table

gtsave(table,"table3.png")

 

