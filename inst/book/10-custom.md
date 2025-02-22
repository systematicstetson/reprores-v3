# Customising Visualisations & Reports {#custom}

## Learning Objectives {#ilo-custom}

* Create and customise advanced types of plots
* Structure data in report, presentation, and dashboard formats
* Include linked figures, tables, and references

## Visualisation {#custom-viz}

### Set-up {#setup-custom-viz}

First, create a new project for the work we'll do in this chapter named <code class='path'>10-advanced</code>. Second, open and save a new R Markdown document named `visualisations.Rmd`, delete the welcome text and load the required packages for this section. You will probably need to install several new packages.


```r
library(tidyverse)   # data wrangling functions
library(ggthemes)    # for themes
library(patchwork)   # for combining plots
library(plotly)      # for interactive plots
# devtools::install_github("hrbrmstr/waffle")
library(waffle)      # for waffle plots
library(ggbump)      # for bump plots
library(treemap)     # for treemap plots
library(ggwordcloud) # for word clouds
library(tidytext)    # for manipulating text for word clouds
library(sf)          # for mapping geoms
library(rnaturalearth) # for map data
library(rnaturalearthdata) # extra mapping data
library(gganimate)   # for animated plots

theme_set(theme_light())
```

You'll need to make a folder called "data" and download data files into it: 
<a href="https://psyteachr.github.io/reprores-v3/data/survey_data.csv" download>survey_data.csv</a> and <a href="https://psyteachr.github.io/reprores-v3/data/scottish_population.csv" download>scottish_population.csv</a>.

Download the [ggplot2 cheat sheet](https://raw.githubusercontent.com/rstudio/cheatsheets/main/data-visualization.pdf).


### Defaults

The code below creates two plots using the default (light) theme and palettes. First, load the data and set `issue_category` to a factor so you can control the order of the categories.


```r
# update column specification
ct <- cols(issue_category = col_factor(
        levels = c("tech", "returns", "sales", "other")
      ))

# load data
survey_data <- read_csv(file = "data/survey_data.csv",
                        col_types = ct)
```

Next, create a bar plot of number of calls by issue category.


```r
# create bar plot
bar <- ggplot(data = survey_data, 
              mapping = aes(x = issue_category,
                            fill = issue_category)) +
  geom_bar(show.legend = FALSE) +
  labs(x = "Issue Category", 
       y = "Count",
       title = "Calls by Issue Category")
```

And create a scatterplot of wait time by call time, distinguished by issue category.


```r
#create scatterplot
point <- ggplot(data = survey_data, 
                mapping = aes(x = wait_time, 
                              y = call_time,
                              color = issue_category)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = lm, formula = y~x) +
  labs(x = "Wait Time",
       y = "Call Time",
       color = "Issue Category",
       title = "Wait Time by Call Time")
```

Finally, combine the two plots using the `+` from <code class='package'>patchwork</code> to see the default styles for these plots.


```r
bar + point
```

<div class="figure" style="text-align: center">
<img src="10-custom_files/figure-html/unnamed-chunk-4-1.png" alt="Default plot styles." width="100%" />
<p class="caption">(\#fig:unnamed-chunk-4)Default plot styles.</p>
</div>

::: {.try data-latex=""}
Try changing the theme using built-in themes or customising the colours or linetypes with scale_* functions. See Appendix\ \@ref(plotstyle) for details.
:::


### Annotations

It's often useful to add annotations to a plot, for example, to highlight an important part of the plot or add labels. The `annotate()` function creates a specific geom at x- and y-coordinates you specify. 

#### Text annotations

Add a text annotation by setting the `geom` argument to "text" or "label" and adding a `label`. Labels have padding and a background, while text is just text.

* Backslash-n `\n` in the label text controls where the line breaks are. Try removing or changing the position of these to see what happens. 
* `x` and `y` control the coordinates of the label. You will likely have to play around with these values to get them right.
* The argument `hjust` is the horizontal justification of text, and `vjust` is the vertical justification. The default values are 0.5, where the text is centred on the x and y coordinates. 0 will justify to the left and bottom, while 1 justifies to the right and top. 
* You can  change the `angle` of text, but not labels.


```r
bar +
  # add left-justified text to the second bar
  annotate(geom = "text",
           label = "Our goal is to\nreduce this\ncategory",
           x = 1.65, y = 150,
           hjust = 0, vjust = 1, 
           color = "white", fontface = "bold",
           angle = 45) +
  # add a centred label to the third bar
  annotate(geom = "label",
           label = "Our goal is\nto increase this\ncategory",
           x = 3, y = 75,
           hjust = 0.5, vjust = 1, 
           color = " darkturquoise", fontface = "bold")
```

<div class="figure" style="text-align: center">
<img src="10-custom_files/figure-html/annotate-text-1.png" alt="An example of annotation text and label." width="100%" />
<p class="caption">(\#fig:annotate-text)An example of annotation text and label.</p>
</div>


::: {.try data-latex=""}

See if you can work out how to make the figure below, starting with the following:


```r
tibble(x = c(0, 0, 1, 1),
       y = c(0, 1, 0, 1)) |>
  ggplot(aes(x, y)) +
  geom_point(alpha = 0.25, size = 4, color = "red")
```

Hint: you will need to add 1 label annotation and 8 separate text annotations.

<img src="10-custom_files/figure-html/unnamed-chunk-6-1.png" width="100%" style="display: block; margin: auto;" />



<div class='webex-solution'><button>Solution</button>

```r
tibble(x = c(0, 0, 1, 1),
       y = c(0, 1, 0, 1)) |>
  ggplot(aes(x, y)) +
  geom_point(alpha = 0.25, size = 4, color = "red") +
  annotate("label", label = "In the\nmiddle",
           x = 0.5, y = 0.5,
           fill = "dodgerblue", color = "white",
           label.padding = unit(1, "lines"),
           label.r = unit(1.5, "lines")) +
  annotate("text", label = "Bottom\nLeft",
           x = 0, y = 0, hjust = 0, vjust = 0) +
  annotate("text", label = "Top\nLeft", 
           x = 0, y = 1, hjust = 0, vjust = 1) +
  annotate("text", label = "Bottom\nRight",
           x = 1, y = 0, hjust = 1, vjust = 0) +
  annotate("text", label = "Top\nRight",
           x = 1, y = 1, hjust = 1, vjust = 1) +
  annotate("text", label = "45 degrees",
           x = 0, y = 0.5, hjust = 0, angle = 45) +
  annotate("text", label = "90 degrees",
           x = 0.25, y = 0.5, angle = 90) +
  annotate("text", label = "270 degrees",
           x = 0.75, y = 0.5, angle = 270)+
  annotate("text", label = "-45 degrees",
           x = 1, y = 0.5, hjust = 1, angle = -45)
```


</div>
:::

#### Other annotations

You can add other geoms to highlight parts of a plot. The example below adds a rectangle around a group of points, a text label, a straight arrow from the label to the rectangle, and a curved arrow from the label to an individual point.


```r
point +
  # add a rectangle surrounding long call times
  annotate(geom = "rect",
           xmin = 100, xmax = 275,
           ymin = 140, ymax = 180,
           fill = "transparent", color = "red") +
  # add a text label
  annotate("text",
           x = 260, y = 120,
           label = "outliers") +
  # add an line with an arrow from the text to the box
  annotate(geom = "segment", 
           x = 240, y = 120, 
           xend = 200, yend = 135,
           arrow = arrow(length = unit(0.5, "lines"))) +
  # add a curved line with an arrow 
  # from the text to a wait time outlier
  annotate(geom = "curve", 
          x = 280, y = 120, 
          xend = 320, yend = 45,
          curvature = -0.5,
          arrow = arrow(length = unit(0.5, "lines")))
```

<div class="figure" style="text-align: center">
<img src="10-custom_files/figure-html/annotation-other-1.png" alt="Example of annotatins with the rect, text, segment, and curve geoms." width="100%" />
<p class="caption">(\#fig:annotation-other)Example of annotatins with the rect, text, segment, and curve geoms.</p>
</div>

See the <code class='package'><a href='https://ggforce.data-imaginist.com/' target='_blank'>ggforce</a></code> package for more sophisticated options, such as highlighting a group of points with an ellipse. 

### Other Plots

#### Interactive Plots

The <code class='package'>plotly</code> package can be used to make interactive graphs. Assign your ggplot to a variable and then use the function `ggplotly()` on the plot object. Note that interactive plots only work in HTML files, not PDFs or Word files.


```r
ggplotly(point)
```

<div class="figure" style="text-align: center">

```{=html}
<div id="htmlwidget-953db5621b41882708fb" style="width:100%;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-953db5621b41882708fb">{"x":{"data":[{"x":[169,206,207,132,193,222,213,170,176,209,201,226,208,201,250,130,165,80,232,118,262,206,103,244,242,211,144,189,240,223,231,168,193,190,151,113,194,241,217,249,256,162,210,225,255,178,250,108,74,212,75,107,122,242,138,195,204,184,251,227,168,195,181,211,179,131,249,203,257,157,176,216,183,207,200,274,96,204,250,246,177,224,186,192,140,214,214,176,251,268,138,163,133,137,211,217,199,217,83,215,242,167,225,187,173,23,225,187,207,260,133,190,123,178,180,157,242,188,272,154,194,148,151,241,214,155,127,205,280,171,209,168,180,217,165,115,92,271,214,175,165,146,115,172,212,229,180,116,162,218,178,147,214,170,150,210,205,178,207,224,212,215,211,222,152,161,163,185,254,171,198,158,190,257,245,191,227,150,257,162,189,247,114,219,183,120,176,137,124,194,230,157,222,171,126,214,233,157,129,164,262,167,250,148,222,269,239,166,258,108,200,166,205,220,104,241,207,244,170,212,199,234,147,203,184,165,192,130,240,211,161,166,215,116,246,180,228,214,73,26,261,164,232,184,185,129,197,203,263,158,85,254,249,164,157,236,90,191,209,203,183,129,214,165,203,243,196,178,280,252,214,198,229,158,112,175,195,124,240,218,179,176,150,105,197,86,135,95,100,232,163,178,215,157,186,165,84,169,103,178,263,152,172,106,162,200,216,179,47,189,138],"y":[34,52,41,16,46,46,40,44,52,37,22,26,22,19,34,26,26,19,41,37,26,8,25,36,41,50,11,22,56,66,71,14,49,72,51,40,90,91,75,67,73,65,96,60,66,69,75,60,46,52,38,34,51,54,40,28,52,26,25,28,51,18,22,47,26,14,40,53,42,25,55,20,42,26,33,46,64,57,63,51,61,49,12,60,56,50,20,74,77,88,69,99,38,74,86,97,35,60,29,84,81,80,78,63,46,42,94,105,102,79,56,65,70,76,94,70,98,103,62,84,31,42,46,65,41,35,65,38,65,18,36,24,59,33,19,32,20,86,36,52,46,42,37,25,58,73,35,19,48,33,53,55,25,48,46,48,81,37,62,66,45,57,33,38,51,28,23,36,68,49,36,31,63,48,85,25,55,29,69,51,48,50,10,81,44,24,37,46,36,61,84,152,60,26,76,58,91,21,37,34,71,42,79,41,174,62,47,30,73,45,64,50,72,41,47,33,39,59,32,31,64,73,38,24,31,46,59,54,60,38,18,68,72,152,55,71,62,99,15,38,53,43,14,51,24,21,93,40,80,51,20,32,52,30,41,66,24,41,30,34,20,40,147,33,118,78,25,50,64,27,39,21,29,11,24,15,18,22,39,53,40,19,12,25,32,42,19,11,17,37,16,19,29,11,30,11,25,33,17,8,20,33,29,15,39,21,20,25,7,26,18],"text":["wait_time: 169<br />call_time:  34<br />issue_category: tech","wait_time: 206<br />call_time:  52<br />issue_category: tech","wait_time: 207<br />call_time:  41<br />issue_category: tech","wait_time: 132<br />call_time:  16<br />issue_category: tech","wait_time: 193<br />call_time:  46<br />issue_category: tech","wait_time: 222<br />call_time:  46<br />issue_category: tech","wait_time: 213<br />call_time:  40<br />issue_category: tech","wait_time: 170<br />call_time:  44<br />issue_category: tech","wait_time: 176<br />call_time:  52<br />issue_category: tech","wait_time: 209<br />call_time:  37<br />issue_category: tech","wait_time: 201<br />call_time:  22<br />issue_category: tech","wait_time: 226<br />call_time:  26<br />issue_category: tech","wait_time: 208<br />call_time:  22<br />issue_category: tech","wait_time: 201<br />call_time:  19<br />issue_category: tech","wait_time: 250<br />call_time:  34<br />issue_category: tech","wait_time: 130<br />call_time:  26<br />issue_category: tech","wait_time: 165<br />call_time:  26<br />issue_category: tech","wait_time:  80<br />call_time:  19<br />issue_category: tech","wait_time: 232<br />call_time:  41<br />issue_category: tech","wait_time: 118<br />call_time:  37<br />issue_category: tech","wait_time: 262<br />call_time:  26<br />issue_category: tech","wait_time: 206<br />call_time:   8<br />issue_category: tech","wait_time: 103<br />call_time:  25<br />issue_category: tech","wait_time: 244<br />call_time:  36<br />issue_category: tech","wait_time: 242<br />call_time:  41<br />issue_category: tech","wait_time: 211<br />call_time:  50<br />issue_category: tech","wait_time: 144<br />call_time:  11<br />issue_category: tech","wait_time: 189<br />call_time:  22<br />issue_category: tech","wait_time: 240<br />call_time:  56<br />issue_category: tech","wait_time: 223<br />call_time:  66<br />issue_category: tech","wait_time: 231<br />call_time:  71<br />issue_category: tech","wait_time: 168<br />call_time:  14<br />issue_category: tech","wait_time: 193<br />call_time:  49<br />issue_category: tech","wait_time: 190<br />call_time:  72<br />issue_category: tech","wait_time: 151<br />call_time:  51<br />issue_category: tech","wait_time: 113<br />call_time:  40<br />issue_category: tech","wait_time: 194<br />call_time:  90<br />issue_category: tech","wait_time: 241<br />call_time:  91<br />issue_category: tech","wait_time: 217<br />call_time:  75<br />issue_category: tech","wait_time: 249<br />call_time:  67<br />issue_category: tech","wait_time: 256<br />call_time:  73<br />issue_category: tech","wait_time: 162<br />call_time:  65<br />issue_category: tech","wait_time: 210<br />call_time:  96<br />issue_category: tech","wait_time: 225<br />call_time:  60<br />issue_category: tech","wait_time: 255<br />call_time:  66<br />issue_category: tech","wait_time: 178<br />call_time:  69<br />issue_category: tech","wait_time: 250<br />call_time:  75<br />issue_category: tech","wait_time: 108<br />call_time:  60<br />issue_category: tech","wait_time:  74<br />call_time:  46<br />issue_category: tech","wait_time: 212<br />call_time:  52<br />issue_category: tech","wait_time:  75<br />call_time:  38<br />issue_category: tech","wait_time: 107<br />call_time:  34<br />issue_category: tech","wait_time: 122<br />call_time:  51<br />issue_category: tech","wait_time: 242<br />call_time:  54<br />issue_category: tech","wait_time: 138<br />call_time:  40<br />issue_category: tech","wait_time: 195<br />call_time:  28<br />issue_category: tech","wait_time: 204<br />call_time:  52<br />issue_category: tech","wait_time: 184<br />call_time:  26<br />issue_category: tech","wait_time: 251<br />call_time:  25<br />issue_category: tech","wait_time: 227<br />call_time:  28<br />issue_category: tech","wait_time: 168<br />call_time:  51<br />issue_category: tech","wait_time: 195<br />call_time:  18<br />issue_category: tech","wait_time: 181<br />call_time:  22<br />issue_category: tech","wait_time: 211<br />call_time:  47<br />issue_category: tech","wait_time: 179<br />call_time:  26<br />issue_category: tech","wait_time: 131<br />call_time:  14<br />issue_category: tech","wait_time: 249<br />call_time:  40<br />issue_category: tech","wait_time: 203<br />call_time:  53<br />issue_category: tech","wait_time: 257<br />call_time:  42<br />issue_category: tech","wait_time: 157<br />call_time:  25<br />issue_category: tech","wait_time: 176<br />call_time:  55<br />issue_category: tech","wait_time: 216<br />call_time:  20<br />issue_category: tech","wait_time: 183<br />call_time:  42<br />issue_category: tech","wait_time: 207<br />call_time:  26<br />issue_category: tech","wait_time: 200<br />call_time:  33<br />issue_category: tech","wait_time: 274<br />call_time:  46<br />issue_category: tech","wait_time:  96<br />call_time:  64<br />issue_category: tech","wait_time: 204<br />call_time:  57<br />issue_category: tech","wait_time: 250<br />call_time:  63<br />issue_category: tech","wait_time: 246<br />call_time:  51<br />issue_category: tech","wait_time: 177<br />call_time:  61<br />issue_category: tech","wait_time: 224<br />call_time:  49<br />issue_category: tech","wait_time: 186<br />call_time:  12<br />issue_category: tech","wait_time: 192<br />call_time:  60<br />issue_category: tech","wait_time: 140<br />call_time:  56<br />issue_category: tech","wait_time: 214<br />call_time:  50<br />issue_category: tech","wait_time: 214<br />call_time:  20<br />issue_category: tech","wait_time: 176<br />call_time:  74<br />issue_category: tech","wait_time: 251<br />call_time:  77<br />issue_category: tech","wait_time: 268<br />call_time:  88<br />issue_category: tech","wait_time: 138<br />call_time:  69<br />issue_category: tech","wait_time: 163<br />call_time:  99<br />issue_category: tech","wait_time: 133<br />call_time:  38<br />issue_category: tech","wait_time: 137<br />call_time:  74<br />issue_category: tech","wait_time: 211<br />call_time:  86<br />issue_category: tech","wait_time: 217<br />call_time:  97<br />issue_category: tech","wait_time: 199<br />call_time:  35<br />issue_category: tech","wait_time: 217<br />call_time:  60<br />issue_category: tech","wait_time:  83<br />call_time:  29<br />issue_category: tech","wait_time: 215<br />call_time:  84<br />issue_category: tech","wait_time: 242<br />call_time:  81<br />issue_category: tech","wait_time: 167<br />call_time:  80<br />issue_category: tech","wait_time: 225<br />call_time:  78<br />issue_category: tech","wait_time: 187<br />call_time:  63<br />issue_category: tech","wait_time: 173<br />call_time:  46<br />issue_category: tech","wait_time:  23<br />call_time:  42<br />issue_category: tech","wait_time: 225<br />call_time:  94<br />issue_category: tech","wait_time: 187<br />call_time: 105<br />issue_category: tech","wait_time: 207<br />call_time: 102<br />issue_category: tech","wait_time: 260<br />call_time:  79<br />issue_category: tech","wait_time: 133<br />call_time:  56<br />issue_category: tech","wait_time: 190<br />call_time:  65<br />issue_category: tech","wait_time: 123<br />call_time:  70<br />issue_category: tech","wait_time: 178<br />call_time:  76<br />issue_category: tech","wait_time: 180<br />call_time:  94<br />issue_category: tech","wait_time: 157<br />call_time:  70<br />issue_category: tech","wait_time: 242<br />call_time:  98<br />issue_category: tech","wait_time: 188<br />call_time: 103<br />issue_category: tech","wait_time: 272<br />call_time:  62<br />issue_category: tech","wait_time: 154<br />call_time:  84<br />issue_category: tech","wait_time: 194<br />call_time:  31<br />issue_category: tech","wait_time: 148<br />call_time:  42<br />issue_category: tech","wait_time: 151<br />call_time:  46<br />issue_category: tech","wait_time: 241<br />call_time:  65<br />issue_category: tech","wait_time: 214<br />call_time:  41<br />issue_category: tech","wait_time: 155<br />call_time:  35<br />issue_category: tech","wait_time: 127<br />call_time:  65<br />issue_category: tech","wait_time: 205<br />call_time:  38<br />issue_category: tech","wait_time: 280<br />call_time:  65<br />issue_category: tech","wait_time: 171<br />call_time:  18<br />issue_category: tech","wait_time: 209<br />call_time:  36<br />issue_category: tech","wait_time: 168<br />call_time:  24<br />issue_category: tech","wait_time: 180<br />call_time:  59<br />issue_category: tech","wait_time: 217<br />call_time:  33<br />issue_category: tech","wait_time: 165<br />call_time:  19<br />issue_category: tech","wait_time: 115<br />call_time:  32<br />issue_category: tech","wait_time:  92<br />call_time:  20<br />issue_category: tech","wait_time: 271<br />call_time:  86<br />issue_category: tech","wait_time: 214<br />call_time:  36<br />issue_category: tech","wait_time: 175<br />call_time:  52<br />issue_category: tech","wait_time: 165<br />call_time:  46<br />issue_category: tech","wait_time: 146<br />call_time:  42<br />issue_category: tech","wait_time: 115<br />call_time:  37<br />issue_category: tech","wait_time: 172<br />call_time:  25<br />issue_category: tech","wait_time: 212<br />call_time:  58<br />issue_category: tech","wait_time: 229<br />call_time:  73<br />issue_category: tech","wait_time: 180<br />call_time:  35<br />issue_category: tech","wait_time: 116<br />call_time:  19<br />issue_category: tech","wait_time: 162<br />call_time:  48<br />issue_category: tech","wait_time: 218<br />call_time:  33<br />issue_category: tech","wait_time: 178<br />call_time:  53<br />issue_category: tech","wait_time: 147<br />call_time:  55<br />issue_category: tech","wait_time: 214<br />call_time:  25<br />issue_category: tech","wait_time: 170<br />call_time:  48<br />issue_category: tech","wait_time: 150<br />call_time:  46<br />issue_category: tech","wait_time: 210<br />call_time:  48<br />issue_category: tech","wait_time: 205<br />call_time:  81<br />issue_category: tech","wait_time: 178<br />call_time:  37<br />issue_category: tech","wait_time: 207<br />call_time:  62<br />issue_category: tech","wait_time: 224<br />call_time:  66<br />issue_category: tech","wait_time: 212<br />call_time:  45<br />issue_category: tech","wait_time: 215<br />call_time:  57<br />issue_category: tech","wait_time: 211<br />call_time:  33<br />issue_category: tech","wait_time: 222<br />call_time:  38<br />issue_category: tech","wait_time: 152<br />call_time:  51<br />issue_category: tech","wait_time: 161<br />call_time:  28<br />issue_category: tech","wait_time: 163<br />call_time:  23<br />issue_category: tech","wait_time: 185<br />call_time:  36<br />issue_category: tech","wait_time: 254<br />call_time:  68<br />issue_category: tech","wait_time: 171<br />call_time:  49<br />issue_category: tech","wait_time: 198<br />call_time:  36<br />issue_category: tech","wait_time: 158<br />call_time:  31<br />issue_category: tech","wait_time: 190<br />call_time:  63<br />issue_category: tech","wait_time: 257<br />call_time:  48<br />issue_category: tech","wait_time: 245<br />call_time:  85<br />issue_category: tech","wait_time: 191<br />call_time:  25<br />issue_category: tech","wait_time: 227<br />call_time:  55<br />issue_category: tech","wait_time: 150<br />call_time:  29<br />issue_category: tech","wait_time: 257<br />call_time:  69<br />issue_category: tech","wait_time: 162<br />call_time:  51<br />issue_category: tech","wait_time: 189<br />call_time:  48<br />issue_category: tech","wait_time: 247<br />call_time:  50<br />issue_category: tech","wait_time: 114<br />call_time:  10<br />issue_category: tech","wait_time: 219<br />call_time:  81<br />issue_category: tech","wait_time: 183<br />call_time:  44<br />issue_category: tech","wait_time: 120<br />call_time:  24<br />issue_category: tech","wait_time: 176<br />call_time:  37<br />issue_category: tech","wait_time: 137<br />call_time:  46<br />issue_category: tech","wait_time: 124<br />call_time:  36<br />issue_category: tech","wait_time: 194<br />call_time:  61<br />issue_category: tech","wait_time: 230<br />call_time:  84<br />issue_category: tech","wait_time: 157<br />call_time: 152<br />issue_category: tech","wait_time: 222<br />call_time:  60<br />issue_category: tech","wait_time: 171<br />call_time:  26<br />issue_category: tech","wait_time: 126<br />call_time:  76<br />issue_category: tech","wait_time: 214<br />call_time:  58<br />issue_category: tech","wait_time: 233<br />call_time:  91<br />issue_category: tech","wait_time: 157<br />call_time:  21<br />issue_category: tech","wait_time: 129<br />call_time:  37<br />issue_category: tech","wait_time: 164<br />call_time:  34<br />issue_category: tech","wait_time: 262<br />call_time:  71<br />issue_category: tech","wait_time: 167<br />call_time:  42<br />issue_category: tech","wait_time: 250<br />call_time:  79<br />issue_category: tech","wait_time: 148<br />call_time:  41<br />issue_category: tech","wait_time: 222<br />call_time: 174<br />issue_category: tech","wait_time: 269<br />call_time:  62<br />issue_category: tech","wait_time: 239<br />call_time:  47<br />issue_category: tech","wait_time: 166<br />call_time:  30<br />issue_category: tech","wait_time: 258<br />call_time:  73<br />issue_category: tech","wait_time: 108<br />call_time:  45<br />issue_category: tech","wait_time: 200<br />call_time:  64<br />issue_category: tech","wait_time: 166<br />call_time:  50<br />issue_category: tech","wait_time: 205<br />call_time:  72<br />issue_category: tech","wait_time: 220<br />call_time:  41<br />issue_category: tech","wait_time: 104<br />call_time:  47<br />issue_category: tech","wait_time: 241<br />call_time:  33<br />issue_category: tech","wait_time: 207<br />call_time:  39<br />issue_category: tech","wait_time: 244<br />call_time:  59<br />issue_category: tech","wait_time: 170<br />call_time:  32<br />issue_category: tech","wait_time: 212<br />call_time:  31<br />issue_category: tech","wait_time: 199<br />call_time:  64<br />issue_category: tech","wait_time: 234<br />call_time:  73<br />issue_category: tech","wait_time: 147<br />call_time:  38<br />issue_category: tech","wait_time: 203<br />call_time:  24<br />issue_category: tech","wait_time: 184<br />call_time:  31<br />issue_category: tech","wait_time: 165<br />call_time:  46<br />issue_category: tech","wait_time: 192<br />call_time:  59<br />issue_category: tech","wait_time: 130<br />call_time:  54<br />issue_category: tech","wait_time: 240<br />call_time:  60<br />issue_category: tech","wait_time: 211<br />call_time:  38<br />issue_category: tech","wait_time: 161<br />call_time:  18<br />issue_category: tech","wait_time: 166<br />call_time:  68<br />issue_category: tech","wait_time: 215<br />call_time:  72<br />issue_category: tech","wait_time: 116<br />call_time: 152<br />issue_category: tech","wait_time: 246<br />call_time:  55<br />issue_category: tech","wait_time: 180<br />call_time:  71<br />issue_category: tech","wait_time: 228<br />call_time:  62<br />issue_category: tech","wait_time: 214<br />call_time:  99<br />issue_category: tech","wait_time:  73<br />call_time:  15<br />issue_category: tech","wait_time:  26<br />call_time:  38<br />issue_category: tech","wait_time: 261<br />call_time:  53<br />issue_category: tech","wait_time: 164<br />call_time:  43<br />issue_category: tech","wait_time: 232<br />call_time:  14<br />issue_category: tech","wait_time: 184<br />call_time:  51<br />issue_category: tech","wait_time: 185<br />call_time:  24<br />issue_category: tech","wait_time: 129<br />call_time:  21<br />issue_category: tech","wait_time: 197<br />call_time:  93<br />issue_category: tech","wait_time: 203<br />call_time:  40<br />issue_category: tech","wait_time: 263<br />call_time:  80<br />issue_category: tech","wait_time: 158<br />call_time:  51<br />issue_category: tech","wait_time:  85<br />call_time:  20<br />issue_category: tech","wait_time: 254<br />call_time:  32<br />issue_category: tech","wait_time: 249<br />call_time:  52<br />issue_category: tech","wait_time: 164<br />call_time:  30<br />issue_category: tech","wait_time: 157<br />call_time:  41<br />issue_category: tech","wait_time: 236<br />call_time:  66<br />issue_category: tech","wait_time:  90<br />call_time:  24<br />issue_category: tech","wait_time: 191<br />call_time:  41<br />issue_category: tech","wait_time: 209<br />call_time:  30<br />issue_category: tech","wait_time: 203<br />call_time:  34<br />issue_category: tech","wait_time: 183<br />call_time:  20<br />issue_category: tech","wait_time: 129<br />call_time:  40<br />issue_category: tech","wait_time: 214<br />call_time: 147<br />issue_category: tech","wait_time: 165<br />call_time:  33<br />issue_category: tech","wait_time: 203<br />call_time: 118<br />issue_category: tech","wait_time: 243<br />call_time:  78<br />issue_category: tech","wait_time: 196<br />call_time:  25<br />issue_category: tech","wait_time: 178<br />call_time:  50<br />issue_category: tech","wait_time: 280<br />call_time:  64<br />issue_category: tech","wait_time: 252<br />call_time:  27<br />issue_category: tech","wait_time: 214<br />call_time:  39<br />issue_category: tech","wait_time: 198<br />call_time:  21<br />issue_category: tech","wait_time: 229<br />call_time:  29<br />issue_category: tech","wait_time: 158<br />call_time:  11<br />issue_category: tech","wait_time: 112<br />call_time:  24<br />issue_category: tech","wait_time: 175<br />call_time:  15<br />issue_category: tech","wait_time: 195<br />call_time:  18<br />issue_category: tech","wait_time: 124<br />call_time:  22<br />issue_category: tech","wait_time: 240<br />call_time:  39<br />issue_category: tech","wait_time: 218<br />call_time:  53<br />issue_category: tech","wait_time: 179<br />call_time:  40<br />issue_category: tech","wait_time: 176<br />call_time:  19<br />issue_category: tech","wait_time: 150<br />call_time:  12<br />issue_category: tech","wait_time: 105<br />call_time:  25<br />issue_category: tech","wait_time: 197<br />call_time:  32<br />issue_category: tech","wait_time:  86<br />call_time:  42<br />issue_category: tech","wait_time: 135<br />call_time:  19<br />issue_category: tech","wait_time:  95<br />call_time:  11<br />issue_category: tech","wait_time: 100<br />call_time:  17<br />issue_category: tech","wait_time: 232<br />call_time:  37<br />issue_category: tech","wait_time: 163<br />call_time:  16<br />issue_category: tech","wait_time: 178<br />call_time:  19<br />issue_category: tech","wait_time: 215<br />call_time:  29<br />issue_category: tech","wait_time: 157<br />call_time:  11<br />issue_category: tech","wait_time: 186<br />call_time:  30<br />issue_category: tech","wait_time: 165<br />call_time:  11<br />issue_category: tech","wait_time:  84<br />call_time:  25<br />issue_category: tech","wait_time: 169<br />call_time:  33<br />issue_category: tech","wait_time: 103<br />call_time:  17<br />issue_category: tech","wait_time: 178<br />call_time:   8<br />issue_category: tech","wait_time: 263<br />call_time:  20<br />issue_category: tech","wait_time: 152<br />call_time:  33<br />issue_category: tech","wait_time: 172<br />call_time:  29<br />issue_category: tech","wait_time: 106<br />call_time:  15<br />issue_category: tech","wait_time: 162<br />call_time:  39<br />issue_category: tech","wait_time: 200<br />call_time:  21<br />issue_category: tech","wait_time: 216<br />call_time:  20<br />issue_category: tech","wait_time: 179<br />call_time:  25<br />issue_category: tech","wait_time:  47<br />call_time:   7<br />issue_category: tech","wait_time: 189<br />call_time:  26<br />issue_category: tech","wait_time: 138<br />call_time:  18<br />issue_category: tech"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(248,118,109,1)","opacity":0.5,"size":5.66929133858268,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(248,118,109,1)"}},"hoveron":"points","name":"tech","legendgroup":"tech","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[178,230,136,224,135,118,212,210,229,314,170,230,154,258,159,186,274,230,217,212,96,212,169,255,189,213,153,157,279,149,208,263,101,164,194,200,111,189,265,245,117,152,198,217,162,211,125,180,260,102,135,242,150,193,128,120,202,48,206,197,236,169,149,235,199,210,235,270,151,230,180,121,228,207,116,72,260,222,170,64,178,154,117,230,141,249,122,269,236,207,183,112,176,128,227,242,250,228,186,131,87,206,192,197,188,148,94,227,76,278,132,154,219,179,183,213,141,146,53,252,223,255,194,204,206,70,220,167,120,70,238,111,107,132,140,209,205,128,194,189,213,186,89,270,277,133,167,235,129,151,190,190,145,236,150,207,223,206,201,224,204,235,236,252,174,204,238,181,118,59,228,165,235,205,180,218,242,134,214,224,237,176,254,184,233,225,179,186,261,152,127,222,154,249,205,195,159,218,196,240,129,217,59,170,153,260,194,146,183,223,263,252,135,135,209,172,232,200,121,123,211,205,209,141,238,165,261,191,227,188,281,196],"y":[20,46,20,22,25,23,48,72,17,40,46,31,25,24,39,27,58,42,18,39,20,52,35,82,37,63,54,52,75,68,54,60,61,28,68,57,59,45,52,80,32,32,43,35,49,37,8,50,64,19,27,42,30,33,45,41,29,23,12,20,58,20,23,58,32,87,33,42,61,40,12,76,75,72,66,101,84,82,80,61,81,101,46,73,48,169,64,74,41,47,31,35,23,37,69,63,61,64,62,33,60,51,29,35,32,33,15,44,15,69,41,39,58,44,64,82,34,51,23,45,47,77,30,17,80,47,53,57,64,20,58,66,35,76,50,73,46,30,43,36,70,31,37,63,81,52,76,74,26,63,53,79,34,54,63,31,41,43,32,80,24,41,59,40,45,151,39,55,20,41,63,66,42,26,52,78,64,27,84,69,55,67,57,31,45,41,21,18,54,37,20,30,23,44,30,40,19,44,58,37,30,25,10,11,27,26,37,13,41,17,49,52,12,18,33,41,53,25,33,11,56,30,36,18,33,12,65,17,58,43,42,12],"text":["wait_time: 178<br />call_time:  20<br />issue_category: returns","wait_time: 230<br />call_time:  46<br />issue_category: returns","wait_time: 136<br />call_time:  20<br />issue_category: returns","wait_time: 224<br />call_time:  22<br />issue_category: returns","wait_time: 135<br />call_time:  25<br />issue_category: returns","wait_time: 118<br />call_time:  23<br />issue_category: returns","wait_time: 212<br />call_time:  48<br />issue_category: returns","wait_time: 210<br />call_time:  72<br />issue_category: returns","wait_time: 229<br />call_time:  17<br />issue_category: returns","wait_time: 314<br />call_time:  40<br />issue_category: returns","wait_time: 170<br />call_time:  46<br />issue_category: returns","wait_time: 230<br />call_time:  31<br />issue_category: returns","wait_time: 154<br />call_time:  25<br />issue_category: returns","wait_time: 258<br />call_time:  24<br />issue_category: returns","wait_time: 159<br />call_time:  39<br />issue_category: returns","wait_time: 186<br />call_time:  27<br />issue_category: returns","wait_time: 274<br />call_time:  58<br />issue_category: returns","wait_time: 230<br />call_time:  42<br />issue_category: returns","wait_time: 217<br />call_time:  18<br />issue_category: returns","wait_time: 212<br />call_time:  39<br />issue_category: returns","wait_time:  96<br />call_time:  20<br />issue_category: returns","wait_time: 212<br />call_time:  52<br />issue_category: returns","wait_time: 169<br />call_time:  35<br />issue_category: returns","wait_time: 255<br />call_time:  82<br />issue_category: returns","wait_time: 189<br />call_time:  37<br />issue_category: returns","wait_time: 213<br />call_time:  63<br />issue_category: returns","wait_time: 153<br />call_time:  54<br />issue_category: returns","wait_time: 157<br />call_time:  52<br />issue_category: returns","wait_time: 279<br />call_time:  75<br />issue_category: returns","wait_time: 149<br />call_time:  68<br />issue_category: returns","wait_time: 208<br />call_time:  54<br />issue_category: returns","wait_time: 263<br />call_time:  60<br />issue_category: returns","wait_time: 101<br />call_time:  61<br />issue_category: returns","wait_time: 164<br />call_time:  28<br />issue_category: returns","wait_time: 194<br />call_time:  68<br />issue_category: returns","wait_time: 200<br />call_time:  57<br />issue_category: returns","wait_time: 111<br />call_time:  59<br />issue_category: returns","wait_time: 189<br />call_time:  45<br />issue_category: returns","wait_time: 265<br />call_time:  52<br />issue_category: returns","wait_time: 245<br />call_time:  80<br />issue_category: returns","wait_time: 117<br />call_time:  32<br />issue_category: returns","wait_time: 152<br />call_time:  32<br />issue_category: returns","wait_time: 198<br />call_time:  43<br />issue_category: returns","wait_time: 217<br />call_time:  35<br />issue_category: returns","wait_time: 162<br />call_time:  49<br />issue_category: returns","wait_time: 211<br />call_time:  37<br />issue_category: returns","wait_time: 125<br />call_time:   8<br />issue_category: returns","wait_time: 180<br />call_time:  50<br />issue_category: returns","wait_time: 260<br />call_time:  64<br />issue_category: returns","wait_time: 102<br />call_time:  19<br />issue_category: returns","wait_time: 135<br />call_time:  27<br />issue_category: returns","wait_time: 242<br />call_time:  42<br />issue_category: returns","wait_time: 150<br />call_time:  30<br />issue_category: returns","wait_time: 193<br />call_time:  33<br />issue_category: returns","wait_time: 128<br />call_time:  45<br />issue_category: returns","wait_time: 120<br />call_time:  41<br />issue_category: returns","wait_time: 202<br />call_time:  29<br />issue_category: returns","wait_time:  48<br />call_time:  23<br />issue_category: returns","wait_time: 206<br />call_time:  12<br />issue_category: returns","wait_time: 197<br />call_time:  20<br />issue_category: returns","wait_time: 236<br />call_time:  58<br />issue_category: returns","wait_time: 169<br />call_time:  20<br />issue_category: returns","wait_time: 149<br />call_time:  23<br />issue_category: returns","wait_time: 235<br />call_time:  58<br />issue_category: returns","wait_time: 199<br />call_time:  32<br />issue_category: returns","wait_time: 210<br />call_time:  87<br />issue_category: returns","wait_time: 235<br />call_time:  33<br />issue_category: returns","wait_time: 270<br />call_time:  42<br />issue_category: returns","wait_time: 151<br />call_time:  61<br />issue_category: returns","wait_time: 230<br />call_time:  40<br />issue_category: returns","wait_time: 180<br />call_time:  12<br />issue_category: returns","wait_time: 121<br />call_time:  76<br />issue_category: returns","wait_time: 228<br />call_time:  75<br />issue_category: returns","wait_time: 207<br />call_time:  72<br />issue_category: returns","wait_time: 116<br />call_time:  66<br />issue_category: returns","wait_time:  72<br />call_time: 101<br />issue_category: returns","wait_time: 260<br />call_time:  84<br />issue_category: returns","wait_time: 222<br />call_time:  82<br />issue_category: returns","wait_time: 170<br />call_time:  80<br />issue_category: returns","wait_time:  64<br />call_time:  61<br />issue_category: returns","wait_time: 178<br />call_time:  81<br />issue_category: returns","wait_time: 154<br />call_time: 101<br />issue_category: returns","wait_time: 117<br />call_time:  46<br />issue_category: returns","wait_time: 230<br />call_time:  73<br />issue_category: returns","wait_time: 141<br />call_time:  48<br />issue_category: returns","wait_time: 249<br />call_time: 169<br />issue_category: returns","wait_time: 122<br />call_time:  64<br />issue_category: returns","wait_time: 269<br />call_time:  74<br />issue_category: returns","wait_time: 236<br />call_time:  41<br />issue_category: returns","wait_time: 207<br />call_time:  47<br />issue_category: returns","wait_time: 183<br />call_time:  31<br />issue_category: returns","wait_time: 112<br />call_time:  35<br />issue_category: returns","wait_time: 176<br />call_time:  23<br />issue_category: returns","wait_time: 128<br />call_time:  37<br />issue_category: returns","wait_time: 227<br />call_time:  69<br />issue_category: returns","wait_time: 242<br />call_time:  63<br />issue_category: returns","wait_time: 250<br />call_time:  61<br />issue_category: returns","wait_time: 228<br />call_time:  64<br />issue_category: returns","wait_time: 186<br />call_time:  62<br />issue_category: returns","wait_time: 131<br />call_time:  33<br />issue_category: returns","wait_time:  87<br />call_time:  60<br />issue_category: returns","wait_time: 206<br />call_time:  51<br />issue_category: returns","wait_time: 192<br />call_time:  29<br />issue_category: returns","wait_time: 197<br />call_time:  35<br />issue_category: returns","wait_time: 188<br />call_time:  32<br />issue_category: returns","wait_time: 148<br />call_time:  33<br />issue_category: returns","wait_time:  94<br />call_time:  15<br />issue_category: returns","wait_time: 227<br />call_time:  44<br />issue_category: returns","wait_time:  76<br />call_time:  15<br />issue_category: returns","wait_time: 278<br />call_time:  69<br />issue_category: returns","wait_time: 132<br />call_time:  41<br />issue_category: returns","wait_time: 154<br />call_time:  39<br />issue_category: returns","wait_time: 219<br />call_time:  58<br />issue_category: returns","wait_time: 179<br />call_time:  44<br />issue_category: returns","wait_time: 183<br />call_time:  64<br />issue_category: returns","wait_time: 213<br />call_time:  82<br />issue_category: returns","wait_time: 141<br />call_time:  34<br />issue_category: returns","wait_time: 146<br />call_time:  51<br />issue_category: returns","wait_time:  53<br />call_time:  23<br />issue_category: returns","wait_time: 252<br />call_time:  45<br />issue_category: returns","wait_time: 223<br />call_time:  47<br />issue_category: returns","wait_time: 255<br />call_time:  77<br />issue_category: returns","wait_time: 194<br />call_time:  30<br />issue_category: returns","wait_time: 204<br />call_time:  17<br />issue_category: returns","wait_time: 206<br />call_time:  80<br />issue_category: returns","wait_time:  70<br />call_time:  47<br />issue_category: returns","wait_time: 220<br />call_time:  53<br />issue_category: returns","wait_time: 167<br />call_time:  57<br />issue_category: returns","wait_time: 120<br />call_time:  64<br />issue_category: returns","wait_time:  70<br />call_time:  20<br />issue_category: returns","wait_time: 238<br />call_time:  58<br />issue_category: returns","wait_time: 111<br />call_time:  66<br />issue_category: returns","wait_time: 107<br />call_time:  35<br />issue_category: returns","wait_time: 132<br />call_time:  76<br />issue_category: returns","wait_time: 140<br />call_time:  50<br />issue_category: returns","wait_time: 209<br />call_time:  73<br />issue_category: returns","wait_time: 205<br />call_time:  46<br />issue_category: returns","wait_time: 128<br />call_time:  30<br />issue_category: returns","wait_time: 194<br />call_time:  43<br />issue_category: returns","wait_time: 189<br />call_time:  36<br />issue_category: returns","wait_time: 213<br />call_time:  70<br />issue_category: returns","wait_time: 186<br />call_time:  31<br />issue_category: returns","wait_time:  89<br />call_time:  37<br />issue_category: returns","wait_time: 270<br />call_time:  63<br />issue_category: returns","wait_time: 277<br />call_time:  81<br />issue_category: returns","wait_time: 133<br />call_time:  52<br />issue_category: returns","wait_time: 167<br />call_time:  76<br />issue_category: returns","wait_time: 235<br />call_time:  74<br />issue_category: returns","wait_time: 129<br />call_time:  26<br />issue_category: returns","wait_time: 151<br />call_time:  63<br />issue_category: returns","wait_time: 190<br />call_time:  53<br />issue_category: returns","wait_time: 190<br />call_time:  79<br />issue_category: returns","wait_time: 145<br />call_time:  34<br />issue_category: returns","wait_time: 236<br />call_time:  54<br />issue_category: returns","wait_time: 150<br />call_time:  63<br />issue_category: returns","wait_time: 207<br />call_time:  31<br />issue_category: returns","wait_time: 223<br />call_time:  41<br />issue_category: returns","wait_time: 206<br />call_time:  43<br />issue_category: returns","wait_time: 201<br />call_time:  32<br />issue_category: returns","wait_time: 224<br />call_time:  80<br />issue_category: returns","wait_time: 204<br />call_time:  24<br />issue_category: returns","wait_time: 235<br />call_time:  41<br />issue_category: returns","wait_time: 236<br />call_time:  59<br />issue_category: returns","wait_time: 252<br />call_time:  40<br />issue_category: returns","wait_time: 174<br />call_time:  45<br />issue_category: returns","wait_time: 204<br />call_time: 151<br />issue_category: returns","wait_time: 238<br />call_time:  39<br />issue_category: returns","wait_time: 181<br />call_time:  55<br />issue_category: returns","wait_time: 118<br />call_time:  20<br />issue_category: returns","wait_time:  59<br />call_time:  41<br />issue_category: returns","wait_time: 228<br />call_time:  63<br />issue_category: returns","wait_time: 165<br />call_time:  66<br />issue_category: returns","wait_time: 235<br />call_time:  42<br />issue_category: returns","wait_time: 205<br />call_time:  26<br />issue_category: returns","wait_time: 180<br />call_time:  52<br />issue_category: returns","wait_time: 218<br />call_time:  78<br />issue_category: returns","wait_time: 242<br />call_time:  64<br />issue_category: returns","wait_time: 134<br />call_time:  27<br />issue_category: returns","wait_time: 214<br />call_time:  84<br />issue_category: returns","wait_time: 224<br />call_time:  69<br />issue_category: returns","wait_time: 237<br />call_time:  55<br />issue_category: returns","wait_time: 176<br />call_time:  67<br />issue_category: returns","wait_time: 254<br />call_time:  57<br />issue_category: returns","wait_time: 184<br />call_time:  31<br />issue_category: returns","wait_time: 233<br />call_time:  45<br />issue_category: returns","wait_time: 225<br />call_time:  41<br />issue_category: returns","wait_time: 179<br />call_time:  21<br />issue_category: returns","wait_time: 186<br />call_time:  18<br />issue_category: returns","wait_time: 261<br />call_time:  54<br />issue_category: returns","wait_time: 152<br />call_time:  37<br />issue_category: returns","wait_time: 127<br />call_time:  20<br />issue_category: returns","wait_time: 222<br />call_time:  30<br />issue_category: returns","wait_time: 154<br />call_time:  23<br />issue_category: returns","wait_time: 249<br />call_time:  44<br />issue_category: returns","wait_time: 205<br />call_time:  30<br />issue_category: returns","wait_time: 195<br />call_time:  40<br />issue_category: returns","wait_time: 159<br />call_time:  19<br />issue_category: returns","wait_time: 218<br />call_time:  44<br />issue_category: returns","wait_time: 196<br />call_time:  58<br />issue_category: returns","wait_time: 240<br />call_time:  37<br />issue_category: returns","wait_time: 129<br />call_time:  30<br />issue_category: returns","wait_time: 217<br />call_time:  25<br />issue_category: returns","wait_time:  59<br />call_time:  10<br />issue_category: returns","wait_time: 170<br />call_time:  11<br />issue_category: returns","wait_time: 153<br />call_time:  27<br />issue_category: returns","wait_time: 260<br />call_time:  26<br />issue_category: returns","wait_time: 194<br />call_time:  37<br />issue_category: returns","wait_time: 146<br />call_time:  13<br />issue_category: returns","wait_time: 183<br />call_time:  41<br />issue_category: returns","wait_time: 223<br />call_time:  17<br />issue_category: returns","wait_time: 263<br />call_time:  49<br />issue_category: returns","wait_time: 252<br />call_time:  52<br />issue_category: returns","wait_time: 135<br />call_time:  12<br />issue_category: returns","wait_time: 135<br />call_time:  18<br />issue_category: returns","wait_time: 209<br />call_time:  33<br />issue_category: returns","wait_time: 172<br />call_time:  41<br />issue_category: returns","wait_time: 232<br />call_time:  53<br />issue_category: returns","wait_time: 200<br />call_time:  25<br />issue_category: returns","wait_time: 121<br />call_time:  33<br />issue_category: returns","wait_time: 123<br />call_time:  11<br />issue_category: returns","wait_time: 211<br />call_time:  56<br />issue_category: returns","wait_time: 205<br />call_time:  30<br />issue_category: returns","wait_time: 209<br />call_time:  36<br />issue_category: returns","wait_time: 141<br />call_time:  18<br />issue_category: returns","wait_time: 238<br />call_time:  33<br />issue_category: returns","wait_time: 165<br />call_time:  12<br />issue_category: returns","wait_time: 261<br />call_time:  65<br />issue_category: returns","wait_time: 191<br />call_time:  17<br />issue_category: returns","wait_time: 227<br />call_time:  58<br />issue_category: returns","wait_time: 188<br />call_time:  43<br />issue_category: returns","wait_time: 281<br />call_time:  42<br />issue_category: returns","wait_time: 196<br />call_time:  12<br />issue_category: returns"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(124,174,0,1)","opacity":0.5,"size":5.66929133858268,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(124,174,0,1)"}},"hoveron":"points","name":"returns","legendgroup":"returns","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[267,248,267,156,58,200,105,178,214,212,230,200,192,212,248,69,216,58,102,166,139,243,217,118,263,113,174,229,188,160,115,170,194,225,222,200,183,207,173,109,193,207,230,238,261,90,252,157,226,180,158,215,184,154,218,189,118,223,149,130,106,216,232,153,127,192,227,221,257,199,229,212,190,171,198,164,113,170,260,175,228,217,195,190,169,181,222,186],"y":[34,58,35,15,17,21,53,66,48,92,63,73,40,34,89,28,58,18,40,36,19,67,67,85,87,79,76,81,58,42,82,47,68,52,46,26,27,81,25,21,19,31,45,54,34,33,68,48,51,94,48,42,46,63,81,40,46,42,51,16,26,30,89,53,41,85,74,50,67,39,60,18,53,16,60,17,44,43,61,13,29,52,51,52,36,10,36,29],"text":["wait_time: 267<br />call_time:  34<br />issue_category: sales","wait_time: 248<br />call_time:  58<br />issue_category: sales","wait_time: 267<br />call_time:  35<br />issue_category: sales","wait_time: 156<br />call_time:  15<br />issue_category: sales","wait_time:  58<br />call_time:  17<br />issue_category: sales","wait_time: 200<br />call_time:  21<br />issue_category: sales","wait_time: 105<br />call_time:  53<br />issue_category: sales","wait_time: 178<br />call_time:  66<br />issue_category: sales","wait_time: 214<br />call_time:  48<br />issue_category: sales","wait_time: 212<br />call_time:  92<br />issue_category: sales","wait_time: 230<br />call_time:  63<br />issue_category: sales","wait_time: 200<br />call_time:  73<br />issue_category: sales","wait_time: 192<br />call_time:  40<br />issue_category: sales","wait_time: 212<br />call_time:  34<br />issue_category: sales","wait_time: 248<br />call_time:  89<br />issue_category: sales","wait_time:  69<br />call_time:  28<br />issue_category: sales","wait_time: 216<br />call_time:  58<br />issue_category: sales","wait_time:  58<br />call_time:  18<br />issue_category: sales","wait_time: 102<br />call_time:  40<br />issue_category: sales","wait_time: 166<br />call_time:  36<br />issue_category: sales","wait_time: 139<br />call_time:  19<br />issue_category: sales","wait_time: 243<br />call_time:  67<br />issue_category: sales","wait_time: 217<br />call_time:  67<br />issue_category: sales","wait_time: 118<br />call_time:  85<br />issue_category: sales","wait_time: 263<br />call_time:  87<br />issue_category: sales","wait_time: 113<br />call_time:  79<br />issue_category: sales","wait_time: 174<br />call_time:  76<br />issue_category: sales","wait_time: 229<br />call_time:  81<br />issue_category: sales","wait_time: 188<br />call_time:  58<br />issue_category: sales","wait_time: 160<br />call_time:  42<br />issue_category: sales","wait_time: 115<br />call_time:  82<br />issue_category: sales","wait_time: 170<br />call_time:  47<br />issue_category: sales","wait_time: 194<br />call_time:  68<br />issue_category: sales","wait_time: 225<br />call_time:  52<br />issue_category: sales","wait_time: 222<br />call_time:  46<br />issue_category: sales","wait_time: 200<br />call_time:  26<br />issue_category: sales","wait_time: 183<br />call_time:  27<br />issue_category: sales","wait_time: 207<br />call_time:  81<br />issue_category: sales","wait_time: 173<br />call_time:  25<br />issue_category: sales","wait_time: 109<br />call_time:  21<br />issue_category: sales","wait_time: 193<br />call_time:  19<br />issue_category: sales","wait_time: 207<br />call_time:  31<br />issue_category: sales","wait_time: 230<br />call_time:  45<br />issue_category: sales","wait_time: 238<br />call_time:  54<br />issue_category: sales","wait_time: 261<br />call_time:  34<br />issue_category: sales","wait_time:  90<br />call_time:  33<br />issue_category: sales","wait_time: 252<br />call_time:  68<br />issue_category: sales","wait_time: 157<br />call_time:  48<br />issue_category: sales","wait_time: 226<br />call_time:  51<br />issue_category: sales","wait_time: 180<br />call_time:  94<br />issue_category: sales","wait_time: 158<br />call_time:  48<br />issue_category: sales","wait_time: 215<br />call_time:  42<br />issue_category: sales","wait_time: 184<br />call_time:  46<br />issue_category: sales","wait_time: 154<br />call_time:  63<br />issue_category: sales","wait_time: 218<br />call_time:  81<br />issue_category: sales","wait_time: 189<br />call_time:  40<br />issue_category: sales","wait_time: 118<br />call_time:  46<br />issue_category: sales","wait_time: 223<br />call_time:  42<br />issue_category: sales","wait_time: 149<br />call_time:  51<br />issue_category: sales","wait_time: 130<br />call_time:  16<br />issue_category: sales","wait_time: 106<br />call_time:  26<br />issue_category: sales","wait_time: 216<br />call_time:  30<br />issue_category: sales","wait_time: 232<br />call_time:  89<br />issue_category: sales","wait_time: 153<br />call_time:  53<br />issue_category: sales","wait_time: 127<br />call_time:  41<br />issue_category: sales","wait_time: 192<br />call_time:  85<br />issue_category: sales","wait_time: 227<br />call_time:  74<br />issue_category: sales","wait_time: 221<br />call_time:  50<br />issue_category: sales","wait_time: 257<br />call_time:  67<br />issue_category: sales","wait_time: 199<br />call_time:  39<br />issue_category: sales","wait_time: 229<br />call_time:  60<br />issue_category: sales","wait_time: 212<br />call_time:  18<br />issue_category: sales","wait_time: 190<br />call_time:  53<br />issue_category: sales","wait_time: 171<br />call_time:  16<br />issue_category: sales","wait_time: 198<br />call_time:  60<br />issue_category: sales","wait_time: 164<br />call_time:  17<br />issue_category: sales","wait_time: 113<br />call_time:  44<br />issue_category: sales","wait_time: 170<br />call_time:  43<br />issue_category: sales","wait_time: 260<br />call_time:  61<br />issue_category: sales","wait_time: 175<br />call_time:  13<br />issue_category: sales","wait_time: 228<br />call_time:  29<br />issue_category: sales","wait_time: 217<br />call_time:  52<br />issue_category: sales","wait_time: 195<br />call_time:  51<br />issue_category: sales","wait_time: 190<br />call_time:  52<br />issue_category: sales","wait_time: 169<br />call_time:  36<br />issue_category: sales","wait_time: 181<br />call_time:  10<br />issue_category: sales","wait_time: 222<br />call_time:  36<br />issue_category: sales","wait_time: 186<br />call_time:  29<br />issue_category: sales"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(0,191,196,1)","opacity":0.5,"size":5.66929133858268,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(0,191,196,1)"}},"hoveron":"points","name":"sales","legendgroup":"sales","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[244,216,176,180,182,194,228,195,155,144,156,185,188,221,81,179,216,232,213,199,260,200,101,227,227,168,191,140,125,181,186,129,223,151,199,192,199,135,184,254,152,233,196,139,214,198,112,265,272,245,149,205,173,216,196,217,203,135,206,177,187,164,244,270,39,141,226,181,245,190,168,217,125,167,200,202],"y":[39,34,38,30,36,57,63,64,47,47,61,95,43,33,30,38,45,49,39,10,46,14,10,26,61,45,87,61,77,88,42,41,73,54,49,58,37,24,35,83,59,91,54,29,92,77,54,64,94,169,40,34,48,58,52,71,33,23,92,74,76,33,72,63,30,43,35,12,24,40,16,21,24,35,20,23],"text":["wait_time: 244<br />call_time:  39<br />issue_category: other","wait_time: 216<br />call_time:  34<br />issue_category: other","wait_time: 176<br />call_time:  38<br />issue_category: other","wait_time: 180<br />call_time:  30<br />issue_category: other","wait_time: 182<br />call_time:  36<br />issue_category: other","wait_time: 194<br />call_time:  57<br />issue_category: other","wait_time: 228<br />call_time:  63<br />issue_category: other","wait_time: 195<br />call_time:  64<br />issue_category: other","wait_time: 155<br />call_time:  47<br />issue_category: other","wait_time: 144<br />call_time:  47<br />issue_category: other","wait_time: 156<br />call_time:  61<br />issue_category: other","wait_time: 185<br />call_time:  95<br />issue_category: other","wait_time: 188<br />call_time:  43<br />issue_category: other","wait_time: 221<br />call_time:  33<br />issue_category: other","wait_time:  81<br />call_time:  30<br />issue_category: other","wait_time: 179<br />call_time:  38<br />issue_category: other","wait_time: 216<br />call_time:  45<br />issue_category: other","wait_time: 232<br />call_time:  49<br />issue_category: other","wait_time: 213<br />call_time:  39<br />issue_category: other","wait_time: 199<br />call_time:  10<br />issue_category: other","wait_time: 260<br />call_time:  46<br />issue_category: other","wait_time: 200<br />call_time:  14<br />issue_category: other","wait_time: 101<br />call_time:  10<br />issue_category: other","wait_time: 227<br />call_time:  26<br />issue_category: other","wait_time: 227<br />call_time:  61<br />issue_category: other","wait_time: 168<br />call_time:  45<br />issue_category: other","wait_time: 191<br />call_time:  87<br />issue_category: other","wait_time: 140<br />call_time:  61<br />issue_category: other","wait_time: 125<br />call_time:  77<br />issue_category: other","wait_time: 181<br />call_time:  88<br />issue_category: other","wait_time: 186<br />call_time:  42<br />issue_category: other","wait_time: 129<br />call_time:  41<br />issue_category: other","wait_time: 223<br />call_time:  73<br />issue_category: other","wait_time: 151<br />call_time:  54<br />issue_category: other","wait_time: 199<br />call_time:  49<br />issue_category: other","wait_time: 192<br />call_time:  58<br />issue_category: other","wait_time: 199<br />call_time:  37<br />issue_category: other","wait_time: 135<br />call_time:  24<br />issue_category: other","wait_time: 184<br />call_time:  35<br />issue_category: other","wait_time: 254<br />call_time:  83<br />issue_category: other","wait_time: 152<br />call_time:  59<br />issue_category: other","wait_time: 233<br />call_time:  91<br />issue_category: other","wait_time: 196<br />call_time:  54<br />issue_category: other","wait_time: 139<br />call_time:  29<br />issue_category: other","wait_time: 214<br />call_time:  92<br />issue_category: other","wait_time: 198<br />call_time:  77<br />issue_category: other","wait_time: 112<br />call_time:  54<br />issue_category: other","wait_time: 265<br />call_time:  64<br />issue_category: other","wait_time: 272<br />call_time:  94<br />issue_category: other","wait_time: 245<br />call_time: 169<br />issue_category: other","wait_time: 149<br />call_time:  40<br />issue_category: other","wait_time: 205<br />call_time:  34<br />issue_category: other","wait_time: 173<br />call_time:  48<br />issue_category: other","wait_time: 216<br />call_time:  58<br />issue_category: other","wait_time: 196<br />call_time:  52<br />issue_category: other","wait_time: 217<br />call_time:  71<br />issue_category: other","wait_time: 203<br />call_time:  33<br />issue_category: other","wait_time: 135<br />call_time:  23<br />issue_category: other","wait_time: 206<br />call_time:  92<br />issue_category: other","wait_time: 177<br />call_time:  74<br />issue_category: other","wait_time: 187<br />call_time:  76<br />issue_category: other","wait_time: 164<br />call_time:  33<br />issue_category: other","wait_time: 244<br />call_time:  72<br />issue_category: other","wait_time: 270<br />call_time:  63<br />issue_category: other","wait_time:  39<br />call_time:  30<br />issue_category: other","wait_time: 141<br />call_time:  43<br />issue_category: other","wait_time: 226<br />call_time:  35<br />issue_category: other","wait_time: 181<br />call_time:  12<br />issue_category: other","wait_time: 245<br />call_time:  24<br />issue_category: other","wait_time: 190<br />call_time:  40<br />issue_category: other","wait_time: 168<br />call_time:  16<br />issue_category: other","wait_time: 217<br />call_time:  21<br />issue_category: other","wait_time: 125<br />call_time:  24<br />issue_category: other","wait_time: 167<br />call_time:  35<br />issue_category: other","wait_time: 200<br />call_time:  20<br />issue_category: other","wait_time: 202<br />call_time:  23<br />issue_category: other"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(199,124,255,1)","opacity":0.5,"size":5.66929133858268,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(199,124,255,1)"}},"hoveron":"points","name":"other","legendgroup":"other","showlegend":true,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[23,26.253164556962,29.506329113924,32.7594936708861,36.0126582278481,39.2658227848101,42.5189873417722,45.7721518987342,49.0253164556962,52.2784810126582,55.5316455696203,58.7848101265823,62.0379746835443,65.2911392405063,68.5443037974684,71.7974683544304,75.0506329113924,78.3037974683544,81.5569620253165,84.8101265822785,88.0632911392405,91.3164556962025,94.5696202531646,97.8227848101266,101.075949367089,104.329113924051,107.582278481013,110.835443037975,114.088607594937,117.341772151899,120.594936708861,123.848101265823,127.101265822785,130.354430379747,133.607594936709,136.860759493671,140.113924050633,143.367088607595,146.620253164557,149.873417721519,153.126582278481,156.379746835443,159.632911392405,162.886075949367,166.139240506329,169.392405063291,172.645569620253,175.898734177215,179.151898734177,182.405063291139,185.658227848101,188.911392405063,192.164556962025,195.417721518987,198.670886075949,201.924050632911,205.177215189873,208.430379746835,211.683544303797,214.936708860759,218.189873417722,221.443037974684,224.696202531646,227.949367088608,231.20253164557,234.455696202532,237.708860759494,240.962025316456,244.215189873418,247.46835443038,250.721518987342,253.974683544304,257.227848101266,260.481012658228,263.73417721519,266.987341772152,270.240506329114,273.493670886076,276.746835443038,280],"y":[20.0972251940229,20.6401533349316,21.1830814758402,21.7260096167488,22.2689377576575,22.8118658985661,23.3547940394748,23.8977221803834,24.4406503212921,24.9835784622007,25.5265066031094,26.069434744018,26.6123628849266,27.1552910258353,27.6982191667439,28.2411473076526,28.7840754485612,29.3270035894699,29.8699317303785,30.4128598712872,30.9557880121958,31.4987161531044,32.0416442940131,32.5845724349217,33.1275005758304,33.670428716739,34.2133568576477,34.7562849985563,35.299213139465,35.8421412803736,36.3850694212822,36.9279975621909,37.4709257030995,38.0138538440082,38.5567819849168,39.0997101258255,39.6426382667341,40.1855664076428,40.7284945485514,41.27142268946,41.8143508303687,42.3572789712773,42.900207112186,43.4431352530946,43.9860633940033,44.5289915349119,45.0719196758205,45.6148478167292,46.1577759576378,46.7007040985465,47.2436322394551,47.7865603803638,48.3294885212724,48.8724166621811,49.4153448030897,49.9582729439983,50.501201084907,51.0441292258156,51.5870573667243,52.1299855076329,52.6729136485416,53.2158417894502,53.7587699303589,54.3016980712675,54.8446262121761,55.3875543530848,55.9304824939934,56.4734106349021,57.0163387758107,57.5592669167194,58.102195057628,58.6451231985367,59.1880513394453,59.730979480354,60.2739076212626,60.8168357621712,61.3597639030799,61.9026920439885,62.4456201848972,62.9885483258058],"text":["wait_time:  23.00000<br />call_time: 20.09723<br />issue_category: tech","wait_time:  26.25316<br />call_time: 20.64015<br />issue_category: tech","wait_time:  29.50633<br />call_time: 21.18308<br />issue_category: tech","wait_time:  32.75949<br />call_time: 21.72601<br />issue_category: tech","wait_time:  36.01266<br />call_time: 22.26894<br />issue_category: tech","wait_time:  39.26582<br />call_time: 22.81187<br />issue_category: tech","wait_time:  42.51899<br />call_time: 23.35479<br />issue_category: tech","wait_time:  45.77215<br />call_time: 23.89772<br />issue_category: tech","wait_time:  49.02532<br />call_time: 24.44065<br />issue_category: tech","wait_time:  52.27848<br />call_time: 24.98358<br />issue_category: tech","wait_time:  55.53165<br />call_time: 25.52651<br />issue_category: tech","wait_time:  58.78481<br />call_time: 26.06943<br />issue_category: tech","wait_time:  62.03797<br />call_time: 26.61236<br />issue_category: tech","wait_time:  65.29114<br />call_time: 27.15529<br />issue_category: tech","wait_time:  68.54430<br />call_time: 27.69822<br />issue_category: tech","wait_time:  71.79747<br />call_time: 28.24115<br />issue_category: tech","wait_time:  75.05063<br />call_time: 28.78408<br />issue_category: tech","wait_time:  78.30380<br />call_time: 29.32700<br />issue_category: tech","wait_time:  81.55696<br />call_time: 29.86993<br />issue_category: tech","wait_time:  84.81013<br />call_time: 30.41286<br />issue_category: tech","wait_time:  88.06329<br />call_time: 30.95579<br />issue_category: tech","wait_time:  91.31646<br />call_time: 31.49872<br />issue_category: tech","wait_time:  94.56962<br />call_time: 32.04164<br />issue_category: tech","wait_time:  97.82278<br />call_time: 32.58457<br />issue_category: tech","wait_time: 101.07595<br />call_time: 33.12750<br />issue_category: tech","wait_time: 104.32911<br />call_time: 33.67043<br />issue_category: tech","wait_time: 107.58228<br />call_time: 34.21336<br />issue_category: tech","wait_time: 110.83544<br />call_time: 34.75628<br />issue_category: tech","wait_time: 114.08861<br />call_time: 35.29921<br />issue_category: tech","wait_time: 117.34177<br />call_time: 35.84214<br />issue_category: tech","wait_time: 120.59494<br />call_time: 36.38507<br />issue_category: tech","wait_time: 123.84810<br />call_time: 36.92800<br />issue_category: tech","wait_time: 127.10127<br />call_time: 37.47093<br />issue_category: tech","wait_time: 130.35443<br />call_time: 38.01385<br />issue_category: tech","wait_time: 133.60759<br />call_time: 38.55678<br />issue_category: tech","wait_time: 136.86076<br />call_time: 39.09971<br />issue_category: tech","wait_time: 140.11392<br />call_time: 39.64264<br />issue_category: tech","wait_time: 143.36709<br />call_time: 40.18557<br />issue_category: tech","wait_time: 146.62025<br />call_time: 40.72849<br />issue_category: tech","wait_time: 149.87342<br />call_time: 41.27142<br />issue_category: tech","wait_time: 153.12658<br />call_time: 41.81435<br />issue_category: tech","wait_time: 156.37975<br />call_time: 42.35728<br />issue_category: tech","wait_time: 159.63291<br />call_time: 42.90021<br />issue_category: tech","wait_time: 162.88608<br />call_time: 43.44314<br />issue_category: tech","wait_time: 166.13924<br />call_time: 43.98606<br />issue_category: tech","wait_time: 169.39241<br />call_time: 44.52899<br />issue_category: tech","wait_time: 172.64557<br />call_time: 45.07192<br />issue_category: tech","wait_time: 175.89873<br />call_time: 45.61485<br />issue_category: tech","wait_time: 179.15190<br />call_time: 46.15778<br />issue_category: tech","wait_time: 182.40506<br />call_time: 46.70070<br />issue_category: tech","wait_time: 185.65823<br />call_time: 47.24363<br />issue_category: tech","wait_time: 188.91139<br />call_time: 47.78656<br />issue_category: tech","wait_time: 192.16456<br />call_time: 48.32949<br />issue_category: tech","wait_time: 195.41772<br />call_time: 48.87242<br />issue_category: tech","wait_time: 198.67089<br />call_time: 49.41534<br />issue_category: tech","wait_time: 201.92405<br />call_time: 49.95827<br />issue_category: tech","wait_time: 205.17722<br />call_time: 50.50120<br />issue_category: tech","wait_time: 208.43038<br />call_time: 51.04413<br />issue_category: tech","wait_time: 211.68354<br />call_time: 51.58706<br />issue_category: tech","wait_time: 214.93671<br />call_time: 52.12999<br />issue_category: tech","wait_time: 218.18987<br />call_time: 52.67291<br />issue_category: tech","wait_time: 221.44304<br />call_time: 53.21584<br />issue_category: tech","wait_time: 224.69620<br />call_time: 53.75877<br />issue_category: tech","wait_time: 227.94937<br />call_time: 54.30170<br />issue_category: tech","wait_time: 231.20253<br />call_time: 54.84463<br />issue_category: tech","wait_time: 234.45570<br />call_time: 55.38755<br />issue_category: tech","wait_time: 237.70886<br />call_time: 55.93048<br />issue_category: tech","wait_time: 240.96203<br />call_time: 56.47341<br />issue_category: tech","wait_time: 244.21519<br />call_time: 57.01634<br />issue_category: tech","wait_time: 247.46835<br />call_time: 57.55927<br />issue_category: tech","wait_time: 250.72152<br />call_time: 58.10220<br />issue_category: tech","wait_time: 253.97468<br />call_time: 58.64512<br />issue_category: tech","wait_time: 257.22785<br />call_time: 59.18805<br />issue_category: tech","wait_time: 260.48101<br />call_time: 59.73098<br />issue_category: tech","wait_time: 263.73418<br />call_time: 60.27391<br />issue_category: tech","wait_time: 266.98734<br />call_time: 60.81684<br />issue_category: tech","wait_time: 270.24051<br />call_time: 61.35976<br />issue_category: tech","wait_time: 273.49367<br />call_time: 61.90269<br />issue_category: tech","wait_time: 276.74684<br />call_time: 62.44562<br />issue_category: tech","wait_time: 280.00000<br />call_time: 62.98855<br />issue_category: tech"],"type":"scatter","mode":"lines","name":"tech","line":{"width":3.77952755905512,"color":"rgba(248,118,109,1)","dash":"solid"},"hoveron":"points","legendgroup":"tech","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[48,51.3670886075949,54.7341772151899,58.1012658227848,61.4683544303797,64.8354430379747,68.2025316455696,71.5696202531646,74.9367088607595,78.3037974683544,81.6708860759494,85.0379746835443,88.4050632911392,91.7721518987342,95.1392405063291,98.5063291139241,101.873417721519,105.240506329114,108.607594936709,111.974683544304,115.341772151899,118.708860759494,122.075949367089,125.443037974684,128.810126582278,132.177215189873,135.544303797468,138.911392405063,142.278481012658,145.645569620253,149.012658227848,152.379746835443,155.746835443038,159.113924050633,162.481012658228,165.848101265823,169.215189873418,172.582278481013,175.949367088608,179.316455696203,182.683544303797,186.050632911392,189.417721518987,192.784810126582,196.151898734177,199.518987341772,202.886075949367,206.253164556962,209.620253164557,212.987341772152,216.354430379747,219.721518987342,223.088607594937,226.455696202532,229.822784810127,233.189873417722,236.556962025316,239.924050632911,243.291139240506,246.658227848101,250.025316455696,253.392405063291,256.759493670886,260.126582278481,263.493670886076,266.860759493671,270.227848101266,273.594936708861,276.962025316456,280.329113924051,283.696202531646,287.063291139241,290.430379746835,293.79746835443,297.164556962025,300.53164556962,303.898734177215,307.26582278481,310.632911392405,314],"y":[28.5216428645678,28.9412344295476,29.3608259945274,29.7804175595072,30.2000091244869,30.6196006894667,31.0391922544465,31.4587838194263,31.878375384406,32.2979669493858,32.7175585143656,33.1371500793454,33.5567416443251,33.9763332093049,34.3959247742847,34.8155163392645,35.2351079042443,35.654699469224,36.0742910342038,36.4938825991836,36.9134741641634,37.3330657291431,37.7526572941229,38.1722488591027,38.5918404240825,39.0114319890622,39.431023554042,39.8506151190218,40.2702066840016,40.6897982489813,41.1093898139611,41.5289813789409,41.9485729439207,42.3681645089004,42.7877560738802,43.20734763886,43.6269392038398,44.0465307688196,44.4661223337993,44.8857138987791,45.3053054637589,45.7248970287387,46.1444885937184,46.5640801586982,46.983671723678,47.4032632886578,47.8228548536375,48.2424464186173,48.6620379835971,49.0816295485769,49.5012211135566,49.9208126785364,50.3404042435162,50.759995808496,51.1795873734757,51.5991789384555,52.0187705034353,52.4383620684151,52.8579536333948,53.2775451983746,53.6971367633544,54.1167283283342,54.536319893314,54.9559114582937,55.3755030232735,55.7950945882533,56.2146861532331,56.6342777182128,57.0538692831926,57.4734608481724,57.8930524131522,58.3126439781319,58.7322355431117,59.1518271080915,59.5714186730713,59.991010238051,60.4106018030308,60.8301933680106,61.2497849329904,61.6693764979701],"text":["wait_time:  48.00000<br />call_time: 28.52164<br />issue_category: returns","wait_time:  51.36709<br />call_time: 28.94123<br />issue_category: returns","wait_time:  54.73418<br />call_time: 29.36083<br />issue_category: returns","wait_time:  58.10127<br />call_time: 29.78042<br />issue_category: returns","wait_time:  61.46835<br />call_time: 30.20001<br />issue_category: returns","wait_time:  64.83544<br />call_time: 30.61960<br />issue_category: returns","wait_time:  68.20253<br />call_time: 31.03919<br />issue_category: returns","wait_time:  71.56962<br />call_time: 31.45878<br />issue_category: returns","wait_time:  74.93671<br />call_time: 31.87838<br />issue_category: returns","wait_time:  78.30380<br />call_time: 32.29797<br />issue_category: returns","wait_time:  81.67089<br />call_time: 32.71756<br />issue_category: returns","wait_time:  85.03797<br />call_time: 33.13715<br />issue_category: returns","wait_time:  88.40506<br />call_time: 33.55674<br />issue_category: returns","wait_time:  91.77215<br />call_time: 33.97633<br />issue_category: returns","wait_time:  95.13924<br />call_time: 34.39592<br />issue_category: returns","wait_time:  98.50633<br />call_time: 34.81552<br />issue_category: returns","wait_time: 101.87342<br />call_time: 35.23511<br />issue_category: returns","wait_time: 105.24051<br />call_time: 35.65470<br />issue_category: returns","wait_time: 108.60759<br />call_time: 36.07429<br />issue_category: returns","wait_time: 111.97468<br />call_time: 36.49388<br />issue_category: returns","wait_time: 115.34177<br />call_time: 36.91347<br />issue_category: returns","wait_time: 118.70886<br />call_time: 37.33307<br />issue_category: returns","wait_time: 122.07595<br />call_time: 37.75266<br />issue_category: returns","wait_time: 125.44304<br />call_time: 38.17225<br />issue_category: returns","wait_time: 128.81013<br />call_time: 38.59184<br />issue_category: returns","wait_time: 132.17722<br />call_time: 39.01143<br />issue_category: returns","wait_time: 135.54430<br />call_time: 39.43102<br />issue_category: returns","wait_time: 138.91139<br />call_time: 39.85062<br />issue_category: returns","wait_time: 142.27848<br />call_time: 40.27021<br />issue_category: returns","wait_time: 145.64557<br />call_time: 40.68980<br />issue_category: returns","wait_time: 149.01266<br />call_time: 41.10939<br />issue_category: returns","wait_time: 152.37975<br />call_time: 41.52898<br />issue_category: returns","wait_time: 155.74684<br />call_time: 41.94857<br />issue_category: returns","wait_time: 159.11392<br />call_time: 42.36816<br />issue_category: returns","wait_time: 162.48101<br />call_time: 42.78776<br />issue_category: returns","wait_time: 165.84810<br />call_time: 43.20735<br />issue_category: returns","wait_time: 169.21519<br />call_time: 43.62694<br />issue_category: returns","wait_time: 172.58228<br />call_time: 44.04653<br />issue_category: returns","wait_time: 175.94937<br />call_time: 44.46612<br />issue_category: returns","wait_time: 179.31646<br />call_time: 44.88571<br />issue_category: returns","wait_time: 182.68354<br />call_time: 45.30531<br />issue_category: returns","wait_time: 186.05063<br />call_time: 45.72490<br />issue_category: returns","wait_time: 189.41772<br />call_time: 46.14449<br />issue_category: returns","wait_time: 192.78481<br />call_time: 46.56408<br />issue_category: returns","wait_time: 196.15190<br />call_time: 46.98367<br />issue_category: returns","wait_time: 199.51899<br />call_time: 47.40326<br />issue_category: returns","wait_time: 202.88608<br />call_time: 47.82285<br />issue_category: returns","wait_time: 206.25316<br />call_time: 48.24245<br />issue_category: returns","wait_time: 209.62025<br />call_time: 48.66204<br />issue_category: returns","wait_time: 212.98734<br />call_time: 49.08163<br />issue_category: returns","wait_time: 216.35443<br />call_time: 49.50122<br />issue_category: returns","wait_time: 219.72152<br />call_time: 49.92081<br />issue_category: returns","wait_time: 223.08861<br />call_time: 50.34040<br />issue_category: returns","wait_time: 226.45570<br />call_time: 50.76000<br />issue_category: returns","wait_time: 229.82278<br />call_time: 51.17959<br />issue_category: returns","wait_time: 233.18987<br />call_time: 51.59918<br />issue_category: returns","wait_time: 236.55696<br />call_time: 52.01877<br />issue_category: returns","wait_time: 239.92405<br />call_time: 52.43836<br />issue_category: returns","wait_time: 243.29114<br />call_time: 52.85795<br />issue_category: returns","wait_time: 246.65823<br />call_time: 53.27755<br />issue_category: returns","wait_time: 250.02532<br />call_time: 53.69714<br />issue_category: returns","wait_time: 253.39241<br />call_time: 54.11673<br />issue_category: returns","wait_time: 256.75949<br />call_time: 54.53632<br />issue_category: returns","wait_time: 260.12658<br />call_time: 54.95591<br />issue_category: returns","wait_time: 263.49367<br />call_time: 55.37550<br />issue_category: returns","wait_time: 266.86076<br />call_time: 55.79509<br />issue_category: returns","wait_time: 270.22785<br />call_time: 56.21469<br />issue_category: returns","wait_time: 273.59494<br />call_time: 56.63428<br />issue_category: returns","wait_time: 276.96203<br />call_time: 57.05387<br />issue_category: returns","wait_time: 280.32911<br />call_time: 57.47346<br />issue_category: returns","wait_time: 283.69620<br />call_time: 57.89305<br />issue_category: returns","wait_time: 287.06329<br />call_time: 58.31264<br />issue_category: returns","wait_time: 290.43038<br />call_time: 58.73224<br />issue_category: returns","wait_time: 293.79747<br />call_time: 59.15183<br />issue_category: returns","wait_time: 297.16456<br />call_time: 59.57142<br />issue_category: returns","wait_time: 300.53165<br />call_time: 59.99101<br />issue_category: returns","wait_time: 303.89873<br />call_time: 60.41060<br />issue_category: returns","wait_time: 307.26582<br />call_time: 60.83019<br />issue_category: returns","wait_time: 310.63291<br />call_time: 61.24978<br />issue_category: returns","wait_time: 314.00000<br />call_time: 61.66938<br />issue_category: returns"],"type":"scatter","mode":"lines","name":"returns","line":{"width":3.77952755905512,"color":"rgba(124,174,0,1)","dash":"solid"},"hoveron":"points","legendgroup":"returns","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[58,60.6455696202532,63.2911392405063,65.9367088607595,68.5822784810127,71.2278481012658,73.873417721519,76.5189873417721,79.1645569620253,81.8101265822785,84.4556962025316,87.1012658227848,89.746835443038,92.3924050632911,95.0379746835443,97.6835443037975,100.329113924051,102.974683544304,105.620253164557,108.26582278481,110.911392405063,113.556962025316,116.20253164557,118.848101265823,121.493670886076,124.139240506329,126.784810126582,129.430379746835,132.075949367089,134.721518987342,137.367088607595,140.012658227848,142.658227848101,145.303797468354,147.949367088608,150.594936708861,153.240506329114,155.886075949367,158.53164556962,161.177215189873,163.822784810127,166.46835443038,169.113924050633,171.759493670886,174.405063291139,177.050632911392,179.696202531646,182.341772151899,184.987341772152,187.632911392405,190.278481012658,192.924050632911,195.569620253165,198.215189873418,200.860759493671,203.506329113924,206.151898734177,208.79746835443,211.443037974684,214.088607594937,216.73417721519,219.379746835443,222.025316455696,224.670886075949,227.316455696203,229.962025316456,232.607594936709,235.253164556962,237.898734177215,240.544303797468,243.189873417722,245.835443037975,248.481012658228,251.126582278481,253.772151898734,256.417721518987,259.063291139241,261.708860759494,264.354430379747,267],"y":[30.696144029874,31.0561406705435,31.416137311213,31.7761339518825,32.136130592552,32.4961272332215,32.856123873891,33.2161205145605,33.57611715523,33.9361137958995,34.2961104365689,34.6561070772384,35.0161037179079,35.3761003585774,35.7360969992469,36.0960936399164,36.4560902805859,36.8160869212554,37.1760835619249,37.5360802025943,37.8960768432638,38.2560734839333,38.6160701246028,38.9760667652723,39.3360634059418,39.6960600466113,40.0560566872808,40.4160533279503,40.7760499686198,41.1360466092892,41.4960432499587,41.8560398906282,42.2160365312977,42.5760331719672,42.9360298126367,43.2960264533062,43.6560230939757,44.0160197346452,44.3760163753146,44.7360130159841,45.0960096566536,45.4560062973231,45.8160029379926,46.1759995786621,46.5359962193316,46.8959928600011,47.2559895006706,47.6159861413401,47.9759827820096,48.335979422679,48.6959760633485,49.055972704018,49.4159693446875,49.775965985357,50.1359626260265,50.495959266696,50.8559559073655,51.215952548035,51.5759491887044,51.9359458293739,52.2959424700434,52.6559391107129,53.0159357513824,53.3759323920519,53.7359290327214,54.0959256733909,54.4559223140604,54.8159189547299,55.1759155953993,55.5359122360688,55.8959088767383,56.2559055174078,56.6159021580773,56.9758987987468,57.3358954394163,57.6958920800858,58.0558887207553,58.4158853614247,58.7758820020942,59.1358786427637],"text":["wait_time:  58.00000<br />call_time: 30.69614<br />issue_category: sales","wait_time:  60.64557<br />call_time: 31.05614<br />issue_category: sales","wait_time:  63.29114<br />call_time: 31.41614<br />issue_category: sales","wait_time:  65.93671<br />call_time: 31.77613<br />issue_category: sales","wait_time:  68.58228<br />call_time: 32.13613<br />issue_category: sales","wait_time:  71.22785<br />call_time: 32.49613<br />issue_category: sales","wait_time:  73.87342<br />call_time: 32.85612<br />issue_category: sales","wait_time:  76.51899<br />call_time: 33.21612<br />issue_category: sales","wait_time:  79.16456<br />call_time: 33.57612<br />issue_category: sales","wait_time:  81.81013<br />call_time: 33.93611<br />issue_category: sales","wait_time:  84.45570<br />call_time: 34.29611<br />issue_category: sales","wait_time:  87.10127<br />call_time: 34.65611<br />issue_category: sales","wait_time:  89.74684<br />call_time: 35.01610<br />issue_category: sales","wait_time:  92.39241<br />call_time: 35.37610<br />issue_category: sales","wait_time:  95.03797<br />call_time: 35.73610<br />issue_category: sales","wait_time:  97.68354<br />call_time: 36.09609<br />issue_category: sales","wait_time: 100.32911<br />call_time: 36.45609<br />issue_category: sales","wait_time: 102.97468<br />call_time: 36.81609<br />issue_category: sales","wait_time: 105.62025<br />call_time: 37.17608<br />issue_category: sales","wait_time: 108.26582<br />call_time: 37.53608<br />issue_category: sales","wait_time: 110.91139<br />call_time: 37.89608<br />issue_category: sales","wait_time: 113.55696<br />call_time: 38.25607<br />issue_category: sales","wait_time: 116.20253<br />call_time: 38.61607<br />issue_category: sales","wait_time: 118.84810<br />call_time: 38.97607<br />issue_category: sales","wait_time: 121.49367<br />call_time: 39.33606<br />issue_category: sales","wait_time: 124.13924<br />call_time: 39.69606<br />issue_category: sales","wait_time: 126.78481<br />call_time: 40.05606<br />issue_category: sales","wait_time: 129.43038<br />call_time: 40.41605<br />issue_category: sales","wait_time: 132.07595<br />call_time: 40.77605<br />issue_category: sales","wait_time: 134.72152<br />call_time: 41.13605<br />issue_category: sales","wait_time: 137.36709<br />call_time: 41.49604<br />issue_category: sales","wait_time: 140.01266<br />call_time: 41.85604<br />issue_category: sales","wait_time: 142.65823<br />call_time: 42.21604<br />issue_category: sales","wait_time: 145.30380<br />call_time: 42.57603<br />issue_category: sales","wait_time: 147.94937<br />call_time: 42.93603<br />issue_category: sales","wait_time: 150.59494<br />call_time: 43.29603<br />issue_category: sales","wait_time: 153.24051<br />call_time: 43.65602<br />issue_category: sales","wait_time: 155.88608<br />call_time: 44.01602<br />issue_category: sales","wait_time: 158.53165<br />call_time: 44.37602<br />issue_category: sales","wait_time: 161.17722<br />call_time: 44.73601<br />issue_category: sales","wait_time: 163.82278<br />call_time: 45.09601<br />issue_category: sales","wait_time: 166.46835<br />call_time: 45.45601<br />issue_category: sales","wait_time: 169.11392<br />call_time: 45.81600<br />issue_category: sales","wait_time: 171.75949<br />call_time: 46.17600<br />issue_category: sales","wait_time: 174.40506<br />call_time: 46.53600<br />issue_category: sales","wait_time: 177.05063<br />call_time: 46.89599<br />issue_category: sales","wait_time: 179.69620<br />call_time: 47.25599<br />issue_category: sales","wait_time: 182.34177<br />call_time: 47.61599<br />issue_category: sales","wait_time: 184.98734<br />call_time: 47.97598<br />issue_category: sales","wait_time: 187.63291<br />call_time: 48.33598<br />issue_category: sales","wait_time: 190.27848<br />call_time: 48.69598<br />issue_category: sales","wait_time: 192.92405<br />call_time: 49.05597<br />issue_category: sales","wait_time: 195.56962<br />call_time: 49.41597<br />issue_category: sales","wait_time: 198.21519<br />call_time: 49.77597<br />issue_category: sales","wait_time: 200.86076<br />call_time: 50.13596<br />issue_category: sales","wait_time: 203.50633<br />call_time: 50.49596<br />issue_category: sales","wait_time: 206.15190<br />call_time: 50.85596<br />issue_category: sales","wait_time: 208.79747<br />call_time: 51.21595<br />issue_category: sales","wait_time: 211.44304<br />call_time: 51.57595<br />issue_category: sales","wait_time: 214.08861<br />call_time: 51.93595<br />issue_category: sales","wait_time: 216.73418<br />call_time: 52.29594<br />issue_category: sales","wait_time: 219.37975<br />call_time: 52.65594<br />issue_category: sales","wait_time: 222.02532<br />call_time: 53.01594<br />issue_category: sales","wait_time: 224.67089<br />call_time: 53.37593<br />issue_category: sales","wait_time: 227.31646<br />call_time: 53.73593<br />issue_category: sales","wait_time: 229.96203<br />call_time: 54.09593<br />issue_category: sales","wait_time: 232.60759<br />call_time: 54.45592<br />issue_category: sales","wait_time: 235.25316<br />call_time: 54.81592<br />issue_category: sales","wait_time: 237.89873<br />call_time: 55.17592<br />issue_category: sales","wait_time: 240.54430<br />call_time: 55.53591<br />issue_category: sales","wait_time: 243.18987<br />call_time: 55.89591<br />issue_category: sales","wait_time: 245.83544<br />call_time: 56.25591<br />issue_category: sales","wait_time: 248.48101<br />call_time: 56.61590<br />issue_category: sales","wait_time: 251.12658<br />call_time: 56.97590<br />issue_category: sales","wait_time: 253.77215<br />call_time: 57.33590<br />issue_category: sales","wait_time: 256.41772<br />call_time: 57.69589<br />issue_category: sales","wait_time: 259.06329<br />call_time: 58.05589<br />issue_category: sales","wait_time: 261.70886<br />call_time: 58.41589<br />issue_category: sales","wait_time: 264.35443<br />call_time: 58.77588<br />issue_category: sales","wait_time: 267.00000<br />call_time: 59.13588<br />issue_category: sales"],"type":"scatter","mode":"lines","name":"sales","line":{"width":3.77952755905512,"color":"rgba(0,191,196,1)","dash":"solid"},"hoveron":"points","legendgroup":"sales","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[39,41.9493670886076,44.8987341772152,47.8481012658228,50.7974683544304,53.746835443038,56.6962025316456,59.6455696202532,62.5949367088608,65.5443037974684,68.4936708860759,71.4430379746835,74.3924050632911,77.3417721518987,80.2911392405063,83.2405063291139,86.1898734177215,89.1392405063291,92.0886075949367,95.0379746835443,97.9873417721519,100.936708860759,103.886075949367,106.835443037975,109.784810126582,112.73417721519,115.683544303797,118.632911392405,121.582278481013,124.53164556962,127.481012658228,130.430379746835,133.379746835443,136.329113924051,139.278481012658,142.227848101266,145.177215189873,148.126582278481,151.075949367089,154.025316455696,156.974683544304,159.924050632911,162.873417721519,165.822784810127,168.772151898734,171.721518987342,174.670886075949,177.620253164557,180.569620253165,183.518987341772,186.46835443038,189.417721518987,192.367088607595,195.316455696203,198.26582278481,201.215189873418,204.164556962025,207.113924050633,210.063291139241,213.012658227848,215.962025316456,218.911392405063,221.860759493671,224.810126582278,227.759493670886,230.708860759494,233.658227848101,236.607594936709,239.556962025316,242.506329113924,245.455696202532,248.405063291139,251.354430379747,254.303797468354,257.253164556962,260.20253164557,263.151898734177,266.101265822785,269.050632911392,272],"y":[20.3237391927368,20.9050964970111,21.4864538012855,22.0678111055599,22.6491684098342,23.2305257141086,23.8118830183829,24.3932403226573,24.9745976269316,25.555954931206,26.1373122354804,26.7186695397547,27.3000268440291,27.8813841483034,28.4627414525778,29.0440987568522,29.6254560611265,30.2068133654009,30.7881706696752,31.3695279739496,31.9508852782239,32.5322425824983,33.1135998867726,33.694957191047,34.2763144953214,34.8576717995957,35.4390291038701,36.0203864081444,36.6017437124188,37.1831010166932,37.7644583209675,38.3458156252419,38.9271729295162,39.5085302337906,40.0898875380649,40.6712448423393,41.2526021466137,41.833959450888,42.4153167551624,42.9966740594367,43.5780313637111,44.1593886679854,44.7407459722598,45.3221032765342,45.9034605808085,46.4848178850829,47.0661751893572,47.6475324936316,48.2288897979059,48.8102471021803,49.3916044064547,49.972961710729,50.5543190150034,51.1356763192777,51.7170336235521,52.2983909278264,52.8797482321008,53.4611055363752,54.0424628406495,54.6238201449239,55.2051774491982,55.7865347534726,56.3678920577469,56.9492493620213,57.5306066662957,58.11196397057,58.6933212748444,59.2746785791187,59.8560358833931,60.4373931876674,61.0187504919418,61.6001077962162,62.1814651004905,62.7628224047649,63.3441797090392,63.9255370133136,64.5068943175879,65.0882516218623,65.6696089261367,66.250966230411],"text":["wait_time:  39.00000<br />call_time: 20.32374<br />issue_category: other","wait_time:  41.94937<br />call_time: 20.90510<br />issue_category: other","wait_time:  44.89873<br />call_time: 21.48645<br />issue_category: other","wait_time:  47.84810<br />call_time: 22.06781<br />issue_category: other","wait_time:  50.79747<br />call_time: 22.64917<br />issue_category: other","wait_time:  53.74684<br />call_time: 23.23053<br />issue_category: other","wait_time:  56.69620<br />call_time: 23.81188<br />issue_category: other","wait_time:  59.64557<br />call_time: 24.39324<br />issue_category: other","wait_time:  62.59494<br />call_time: 24.97460<br />issue_category: other","wait_time:  65.54430<br />call_time: 25.55595<br />issue_category: other","wait_time:  68.49367<br />call_time: 26.13731<br />issue_category: other","wait_time:  71.44304<br />call_time: 26.71867<br />issue_category: other","wait_time:  74.39241<br />call_time: 27.30003<br />issue_category: other","wait_time:  77.34177<br />call_time: 27.88138<br />issue_category: other","wait_time:  80.29114<br />call_time: 28.46274<br />issue_category: other","wait_time:  83.24051<br />call_time: 29.04410<br />issue_category: other","wait_time:  86.18987<br />call_time: 29.62546<br />issue_category: other","wait_time:  89.13924<br />call_time: 30.20681<br />issue_category: other","wait_time:  92.08861<br />call_time: 30.78817<br />issue_category: other","wait_time:  95.03797<br />call_time: 31.36953<br />issue_category: other","wait_time:  97.98734<br />call_time: 31.95089<br />issue_category: other","wait_time: 100.93671<br />call_time: 32.53224<br />issue_category: other","wait_time: 103.88608<br />call_time: 33.11360<br />issue_category: other","wait_time: 106.83544<br />call_time: 33.69496<br />issue_category: other","wait_time: 109.78481<br />call_time: 34.27631<br />issue_category: other","wait_time: 112.73418<br />call_time: 34.85767<br />issue_category: other","wait_time: 115.68354<br />call_time: 35.43903<br />issue_category: other","wait_time: 118.63291<br />call_time: 36.02039<br />issue_category: other","wait_time: 121.58228<br />call_time: 36.60174<br />issue_category: other","wait_time: 124.53165<br />call_time: 37.18310<br />issue_category: other","wait_time: 127.48101<br />call_time: 37.76446<br />issue_category: other","wait_time: 130.43038<br />call_time: 38.34582<br />issue_category: other","wait_time: 133.37975<br />call_time: 38.92717<br />issue_category: other","wait_time: 136.32911<br />call_time: 39.50853<br />issue_category: other","wait_time: 139.27848<br />call_time: 40.08989<br />issue_category: other","wait_time: 142.22785<br />call_time: 40.67124<br />issue_category: other","wait_time: 145.17722<br />call_time: 41.25260<br />issue_category: other","wait_time: 148.12658<br />call_time: 41.83396<br />issue_category: other","wait_time: 151.07595<br />call_time: 42.41532<br />issue_category: other","wait_time: 154.02532<br />call_time: 42.99667<br />issue_category: other","wait_time: 156.97468<br />call_time: 43.57803<br />issue_category: other","wait_time: 159.92405<br />call_time: 44.15939<br />issue_category: other","wait_time: 162.87342<br />call_time: 44.74075<br />issue_category: other","wait_time: 165.82278<br />call_time: 45.32210<br />issue_category: other","wait_time: 168.77215<br />call_time: 45.90346<br />issue_category: other","wait_time: 171.72152<br />call_time: 46.48482<br />issue_category: other","wait_time: 174.67089<br />call_time: 47.06618<br />issue_category: other","wait_time: 177.62025<br />call_time: 47.64753<br />issue_category: other","wait_time: 180.56962<br />call_time: 48.22889<br />issue_category: other","wait_time: 183.51899<br />call_time: 48.81025<br />issue_category: other","wait_time: 186.46835<br />call_time: 49.39160<br />issue_category: other","wait_time: 189.41772<br />call_time: 49.97296<br />issue_category: other","wait_time: 192.36709<br />call_time: 50.55432<br />issue_category: other","wait_time: 195.31646<br />call_time: 51.13568<br />issue_category: other","wait_time: 198.26582<br />call_time: 51.71703<br />issue_category: other","wait_time: 201.21519<br />call_time: 52.29839<br />issue_category: other","wait_time: 204.16456<br />call_time: 52.87975<br />issue_category: other","wait_time: 207.11392<br />call_time: 53.46111<br />issue_category: other","wait_time: 210.06329<br />call_time: 54.04246<br />issue_category: other","wait_time: 213.01266<br />call_time: 54.62382<br />issue_category: other","wait_time: 215.96203<br />call_time: 55.20518<br />issue_category: other","wait_time: 218.91139<br />call_time: 55.78653<br />issue_category: other","wait_time: 221.86076<br />call_time: 56.36789<br />issue_category: other","wait_time: 224.81013<br />call_time: 56.94925<br />issue_category: other","wait_time: 227.75949<br />call_time: 57.53061<br />issue_category: other","wait_time: 230.70886<br />call_time: 58.11196<br />issue_category: other","wait_time: 233.65823<br />call_time: 58.69332<br />issue_category: other","wait_time: 236.60759<br />call_time: 59.27468<br />issue_category: other","wait_time: 239.55696<br />call_time: 59.85604<br />issue_category: other","wait_time: 242.50633<br />call_time: 60.43739<br />issue_category: other","wait_time: 245.45570<br />call_time: 61.01875<br />issue_category: other","wait_time: 248.40506<br />call_time: 61.60011<br />issue_category: other","wait_time: 251.35443<br />call_time: 62.18147<br />issue_category: other","wait_time: 254.30380<br />call_time: 62.76282<br />issue_category: other","wait_time: 257.25316<br />call_time: 63.34418<br />issue_category: other","wait_time: 260.20253<br />call_time: 63.92554<br />issue_category: other","wait_time: 263.15190<br />call_time: 64.50689<br />issue_category: other","wait_time: 266.10127<br />call_time: 65.08825<br />issue_category: other","wait_time: 269.05063<br />call_time: 65.66961<br />issue_category: other","wait_time: 272.00000<br />call_time: 66.25097<br />issue_category: other"],"type":"scatter","mode":"lines","name":"other","line":{"width":3.77952755905512,"color":"rgba(199,124,255,1)","dash":"solid"},"hoveron":"points","legendgroup":"other","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[23,26.253164556962,29.506329113924,32.7594936708861,36.0126582278481,39.2658227848101,42.5189873417722,45.7721518987342,49.0253164556962,52.2784810126582,55.5316455696203,58.7848101265823,62.0379746835443,65.2911392405063,68.5443037974684,71.7974683544304,75.0506329113924,78.3037974683544,81.5569620253165,84.8101265822785,88.0632911392405,91.3164556962025,94.5696202531646,97.8227848101266,101.075949367089,104.329113924051,107.582278481013,110.835443037975,114.088607594937,117.341772151899,120.594936708861,123.848101265823,127.101265822785,130.354430379747,133.607594936709,136.860759493671,140.113924050633,143.367088607595,146.620253164557,149.873417721519,153.126582278481,156.379746835443,159.632911392405,162.886075949367,166.139240506329,169.392405063291,172.645569620253,175.898734177215,179.151898734177,182.405063291139,185.658227848101,188.911392405063,192.164556962025,195.417721518987,198.670886075949,201.924050632911,205.177215189873,208.430379746835,211.683544303797,214.936708860759,218.189873417722,221.443037974684,224.696202531646,227.949367088608,231.20253164557,234.455696202532,237.708860759494,240.962025316456,244.215189873418,247.46835443038,250.721518987342,253.974683544304,257.227848101266,260.481012658228,263.73417721519,266.987341772152,270.240506329114,273.493670886076,276.746835443038,280,280,276.746835443038,273.493670886076,270.240506329114,266.987341772152,263.73417721519,260.481012658228,257.227848101266,253.974683544304,250.721518987342,247.46835443038,244.215189873418,240.962025316456,237.708860759494,234.455696202532,231.20253164557,227.949367088608,224.696202531646,221.443037974684,218.189873417722,214.936708860759,211.683544303797,208.430379746835,205.177215189873,201.924050632911,198.670886075949,195.417721518987,192.164556962025,188.911392405063,185.658227848101,182.405063291139,179.151898734177,175.898734177215,172.645569620253,169.392405063291,166.139240506329,162.886075949367,159.632911392405,156.379746835443,153.126582278481,149.873417721519,146.620253164557,143.367088607595,140.113924050633,136.860759493671,133.607594936709,130.354430379747,127.101265822785,123.848101265823,120.594936708861,117.341772151899,114.088607594937,110.835443037975,107.582278481013,104.329113924051,101.075949367089,97.8227848101266,94.5696202531646,91.3164556962025,88.0632911392405,84.8101265822785,81.5569620253165,78.3037974683544,75.0506329113924,71.7974683544304,68.5443037974684,65.2911392405063,62.0379746835443,58.7848101265823,55.5316455696203,52.2784810126582,49.0253164556962,45.7721518987342,42.5189873417722,39.2658227848101,36.0126582278481,32.7594936708861,29.506329113924,26.253164556962,23,23],"y":[10.4957442796768,11.2149601684035,11.9338779004121,12.6524801266009,13.3707481601614,14.0886618488537,14.8061994328519,15.5233373863002,16.2400502404509,16.9563103859532,17.6720878515071,18.387350055691,19.1020615283055,19.8161835970376,20.5296740346318,21.2424866610464,21.9545708942682,22.6658712425342,23.3763267296716,24.0858702440988,24.794427800731,25.5019177036131,26.2082495955761,26.9133233796242,27.6170279951707,28.3192400307814,29.0198221539253,29.718621337657,30.4154668645801,31.1101680904572,31.8025119542936,32.4922602298021,33.1791465264443,33.8628730688269,34.54310731372,35.2194785074786,35.891574346543,36.5589379830271,37.2210657178223,37.877405843515,38.5273592310461,39.17028237997,39.8054937413677,40.432284127986,41.0499318875575,41.6577231698425,42.2549770244905,42.8410742403452,43.4154878836495,43.9778126236689,44.5277894305443,45.0653223501662,45.5904849165279,46.1035152280121,46.6048004371329,47.0948529277573,47.574281403512,48.043760327031,48.5040007159668,48.9557244644458,49.3996434023902,49.8364434533682,50.2667736246596,50.6912391863541,51.1103982336226,51.5247608163418,51.9347899013728,52.340903555964,52.7434778728848,53.1428502799468,53.5393229797697,53.9331663477404,54.3246221784353,54.7139067162724,55.1012134381948,55.4867155779232,55.8705683954447,56.2529112040723,56.63386917228,57.0135549198045,68.9635417318071,68.2573711975144,67.5524728839048,66.848959410715,66.1469559464192,65.4466018043304,64.7480522444355,64.0514805004553,63.357080049333,62.6650671354863,61.9756835534919,61.2891996787366,60.6059177138402,59.9261750866141,59.2503478898277,58.5788541907296,57.9121569561809,57.2507662360581,56.5952401255322,55.9461838946929,55.30424655082,54.6701140174818,54.0444981246002,53.4281207663019,52.8216929602394,52.2258891690465,51.64131809635,51.0684921260169,50.5077984105613,49.9594750483659,49.4235955734241,48.9000640316262,48.3886213931132,47.8888623271506,47.4002598999813,46.922194900449,46.4539863782032,45.9949204830043,45.5442755625847,45.1013424296912,44.6654395354051,44.2359233792805,43.8121948322584,43.3937021869252,42.9799417441723,42.5704566561136,42.1648346191894,41.7627048797547,41.3637348945797,40.9676268882708,40.57411447029,40.1829594143499,39.7939486594556,39.40689156137,39.0216174026966,38.63797315649,38.2558214902192,37.8750389924501,37.4955146025958,37.1171482236605,36.7398494984755,36.3635367310855,35.9881359364056,35.6135800028542,35.2398079542588,34.8667642988561,34.4943984546329,34.1226642415478,33.751519432345,33.3809253547116,33.0108465384482,32.6412504021332,32.2721069744666,31.9033886460976,31.5350699482786,31.1671273551536,30.7995391068968,30.4322850512683,30.0653465014596,29.698706108369,10.4957442796768],"text":["wait_time:  23.00000<br />call_time: 20.09723<br />issue_category: tech","wait_time:  26.25316<br />call_time: 20.64015<br />issue_category: tech","wait_time:  29.50633<br />call_time: 21.18308<br />issue_category: tech","wait_time:  32.75949<br />call_time: 21.72601<br />issue_category: tech","wait_time:  36.01266<br />call_time: 22.26894<br />issue_category: tech","wait_time:  39.26582<br />call_time: 22.81187<br />issue_category: tech","wait_time:  42.51899<br />call_time: 23.35479<br />issue_category: tech","wait_time:  45.77215<br />call_time: 23.89772<br />issue_category: tech","wait_time:  49.02532<br />call_time: 24.44065<br />issue_category: tech","wait_time:  52.27848<br />call_time: 24.98358<br />issue_category: tech","wait_time:  55.53165<br />call_time: 25.52651<br />issue_category: tech","wait_time:  58.78481<br />call_time: 26.06943<br />issue_category: tech","wait_time:  62.03797<br />call_time: 26.61236<br />issue_category: tech","wait_time:  65.29114<br />call_time: 27.15529<br />issue_category: tech","wait_time:  68.54430<br />call_time: 27.69822<br />issue_category: tech","wait_time:  71.79747<br />call_time: 28.24115<br />issue_category: tech","wait_time:  75.05063<br />call_time: 28.78408<br />issue_category: tech","wait_time:  78.30380<br />call_time: 29.32700<br />issue_category: tech","wait_time:  81.55696<br />call_time: 29.86993<br />issue_category: tech","wait_time:  84.81013<br />call_time: 30.41286<br />issue_category: tech","wait_time:  88.06329<br />call_time: 30.95579<br />issue_category: tech","wait_time:  91.31646<br />call_time: 31.49872<br />issue_category: tech","wait_time:  94.56962<br />call_time: 32.04164<br />issue_category: tech","wait_time:  97.82278<br />call_time: 32.58457<br />issue_category: tech","wait_time: 101.07595<br />call_time: 33.12750<br />issue_category: tech","wait_time: 104.32911<br />call_time: 33.67043<br />issue_category: tech","wait_time: 107.58228<br />call_time: 34.21336<br />issue_category: tech","wait_time: 110.83544<br />call_time: 34.75628<br />issue_category: tech","wait_time: 114.08861<br />call_time: 35.29921<br />issue_category: tech","wait_time: 117.34177<br />call_time: 35.84214<br />issue_category: tech","wait_time: 120.59494<br />call_time: 36.38507<br />issue_category: tech","wait_time: 123.84810<br />call_time: 36.92800<br />issue_category: tech","wait_time: 127.10127<br />call_time: 37.47093<br />issue_category: tech","wait_time: 130.35443<br />call_time: 38.01385<br />issue_category: tech","wait_time: 133.60759<br />call_time: 38.55678<br />issue_category: tech","wait_time: 136.86076<br />call_time: 39.09971<br />issue_category: tech","wait_time: 140.11392<br />call_time: 39.64264<br />issue_category: tech","wait_time: 143.36709<br />call_time: 40.18557<br />issue_category: tech","wait_time: 146.62025<br />call_time: 40.72849<br />issue_category: tech","wait_time: 149.87342<br />call_time: 41.27142<br />issue_category: tech","wait_time: 153.12658<br />call_time: 41.81435<br />issue_category: tech","wait_time: 156.37975<br />call_time: 42.35728<br />issue_category: tech","wait_time: 159.63291<br />call_time: 42.90021<br />issue_category: tech","wait_time: 162.88608<br />call_time: 43.44314<br />issue_category: tech","wait_time: 166.13924<br />call_time: 43.98606<br />issue_category: tech","wait_time: 169.39241<br />call_time: 44.52899<br />issue_category: tech","wait_time: 172.64557<br />call_time: 45.07192<br />issue_category: tech","wait_time: 175.89873<br />call_time: 45.61485<br />issue_category: tech","wait_time: 179.15190<br />call_time: 46.15778<br />issue_category: tech","wait_time: 182.40506<br />call_time: 46.70070<br />issue_category: tech","wait_time: 185.65823<br />call_time: 47.24363<br />issue_category: tech","wait_time: 188.91139<br />call_time: 47.78656<br />issue_category: tech","wait_time: 192.16456<br />call_time: 48.32949<br />issue_category: tech","wait_time: 195.41772<br />call_time: 48.87242<br />issue_category: tech","wait_time: 198.67089<br />call_time: 49.41534<br />issue_category: tech","wait_time: 201.92405<br />call_time: 49.95827<br />issue_category: tech","wait_time: 205.17722<br />call_time: 50.50120<br />issue_category: tech","wait_time: 208.43038<br />call_time: 51.04413<br />issue_category: tech","wait_time: 211.68354<br />call_time: 51.58706<br />issue_category: tech","wait_time: 214.93671<br />call_time: 52.12999<br />issue_category: tech","wait_time: 218.18987<br />call_time: 52.67291<br />issue_category: tech","wait_time: 221.44304<br />call_time: 53.21584<br />issue_category: tech","wait_time: 224.69620<br />call_time: 53.75877<br />issue_category: tech","wait_time: 227.94937<br />call_time: 54.30170<br />issue_category: tech","wait_time: 231.20253<br />call_time: 54.84463<br />issue_category: tech","wait_time: 234.45570<br />call_time: 55.38755<br />issue_category: tech","wait_time: 237.70886<br />call_time: 55.93048<br />issue_category: tech","wait_time: 240.96203<br />call_time: 56.47341<br />issue_category: tech","wait_time: 244.21519<br />call_time: 57.01634<br />issue_category: tech","wait_time: 247.46835<br />call_time: 57.55927<br />issue_category: tech","wait_time: 250.72152<br />call_time: 58.10220<br />issue_category: tech","wait_time: 253.97468<br />call_time: 58.64512<br />issue_category: tech","wait_time: 257.22785<br />call_time: 59.18805<br />issue_category: tech","wait_time: 260.48101<br />call_time: 59.73098<br />issue_category: tech","wait_time: 263.73418<br />call_time: 60.27391<br />issue_category: tech","wait_time: 266.98734<br />call_time: 60.81684<br />issue_category: tech","wait_time: 270.24051<br />call_time: 61.35976<br />issue_category: tech","wait_time: 273.49367<br />call_time: 61.90269<br />issue_category: tech","wait_time: 276.74684<br />call_time: 62.44562<br />issue_category: tech","wait_time: 280.00000<br />call_time: 62.98855<br />issue_category: tech","wait_time: 280.00000<br />call_time: 62.98855<br />issue_category: tech","wait_time: 276.74684<br />call_time: 62.44562<br />issue_category: tech","wait_time: 273.49367<br />call_time: 61.90269<br />issue_category: tech","wait_time: 270.24051<br />call_time: 61.35976<br />issue_category: tech","wait_time: 266.98734<br />call_time: 60.81684<br />issue_category: tech","wait_time: 263.73418<br />call_time: 60.27391<br />issue_category: tech","wait_time: 260.48101<br />call_time: 59.73098<br />issue_category: tech","wait_time: 257.22785<br />call_time: 59.18805<br />issue_category: tech","wait_time: 253.97468<br />call_time: 58.64512<br />issue_category: tech","wait_time: 250.72152<br />call_time: 58.10220<br />issue_category: tech","wait_time: 247.46835<br />call_time: 57.55927<br />issue_category: tech","wait_time: 244.21519<br />call_time: 57.01634<br />issue_category: tech","wait_time: 240.96203<br />call_time: 56.47341<br />issue_category: tech","wait_time: 237.70886<br />call_time: 55.93048<br />issue_category: tech","wait_time: 234.45570<br />call_time: 55.38755<br />issue_category: tech","wait_time: 231.20253<br />call_time: 54.84463<br />issue_category: tech","wait_time: 227.94937<br />call_time: 54.30170<br />issue_category: tech","wait_time: 224.69620<br />call_time: 53.75877<br />issue_category: tech","wait_time: 221.44304<br />call_time: 53.21584<br />issue_category: tech","wait_time: 218.18987<br />call_time: 52.67291<br />issue_category: tech","wait_time: 214.93671<br />call_time: 52.12999<br />issue_category: tech","wait_time: 211.68354<br />call_time: 51.58706<br />issue_category: tech","wait_time: 208.43038<br />call_time: 51.04413<br />issue_category: tech","wait_time: 205.17722<br />call_time: 50.50120<br />issue_category: tech","wait_time: 201.92405<br />call_time: 49.95827<br />issue_category: tech","wait_time: 198.67089<br />call_time: 49.41534<br />issue_category: tech","wait_time: 195.41772<br />call_time: 48.87242<br />issue_category: tech","wait_time: 192.16456<br />call_time: 48.32949<br />issue_category: tech","wait_time: 188.91139<br />call_time: 47.78656<br />issue_category: tech","wait_time: 185.65823<br />call_time: 47.24363<br />issue_category: tech","wait_time: 182.40506<br />call_time: 46.70070<br />issue_category: tech","wait_time: 179.15190<br />call_time: 46.15778<br />issue_category: tech","wait_time: 175.89873<br />call_time: 45.61485<br />issue_category: tech","wait_time: 172.64557<br />call_time: 45.07192<br />issue_category: tech","wait_time: 169.39241<br />call_time: 44.52899<br />issue_category: tech","wait_time: 166.13924<br />call_time: 43.98606<br />issue_category: tech","wait_time: 162.88608<br />call_time: 43.44314<br />issue_category: tech","wait_time: 159.63291<br />call_time: 42.90021<br />issue_category: tech","wait_time: 156.37975<br />call_time: 42.35728<br />issue_category: tech","wait_time: 153.12658<br />call_time: 41.81435<br />issue_category: tech","wait_time: 149.87342<br />call_time: 41.27142<br />issue_category: tech","wait_time: 146.62025<br />call_time: 40.72849<br />issue_category: tech","wait_time: 143.36709<br />call_time: 40.18557<br />issue_category: tech","wait_time: 140.11392<br />call_time: 39.64264<br />issue_category: tech","wait_time: 136.86076<br />call_time: 39.09971<br />issue_category: tech","wait_time: 133.60759<br />call_time: 38.55678<br />issue_category: tech","wait_time: 130.35443<br />call_time: 38.01385<br />issue_category: tech","wait_time: 127.10127<br />call_time: 37.47093<br />issue_category: tech","wait_time: 123.84810<br />call_time: 36.92800<br />issue_category: tech","wait_time: 120.59494<br />call_time: 36.38507<br />issue_category: tech","wait_time: 117.34177<br />call_time: 35.84214<br />issue_category: tech","wait_time: 114.08861<br />call_time: 35.29921<br />issue_category: tech","wait_time: 110.83544<br />call_time: 34.75628<br />issue_category: tech","wait_time: 107.58228<br />call_time: 34.21336<br />issue_category: tech","wait_time: 104.32911<br />call_time: 33.67043<br />issue_category: tech","wait_time: 101.07595<br />call_time: 33.12750<br />issue_category: tech","wait_time:  97.82278<br />call_time: 32.58457<br />issue_category: tech","wait_time:  94.56962<br />call_time: 32.04164<br />issue_category: tech","wait_time:  91.31646<br />call_time: 31.49872<br />issue_category: tech","wait_time:  88.06329<br />call_time: 30.95579<br />issue_category: tech","wait_time:  84.81013<br />call_time: 30.41286<br />issue_category: tech","wait_time:  81.55696<br />call_time: 29.86993<br />issue_category: tech","wait_time:  78.30380<br />call_time: 29.32700<br />issue_category: tech","wait_time:  75.05063<br />call_time: 28.78408<br />issue_category: tech","wait_time:  71.79747<br />call_time: 28.24115<br />issue_category: tech","wait_time:  68.54430<br />call_time: 27.69822<br />issue_category: tech","wait_time:  65.29114<br />call_time: 27.15529<br />issue_category: tech","wait_time:  62.03797<br />call_time: 26.61236<br />issue_category: tech","wait_time:  58.78481<br />call_time: 26.06943<br />issue_category: tech","wait_time:  55.53165<br />call_time: 25.52651<br />issue_category: tech","wait_time:  52.27848<br />call_time: 24.98358<br />issue_category: tech","wait_time:  49.02532<br />call_time: 24.44065<br />issue_category: tech","wait_time:  45.77215<br />call_time: 23.89772<br />issue_category: tech","wait_time:  42.51899<br />call_time: 23.35479<br />issue_category: tech","wait_time:  39.26582<br />call_time: 22.81187<br />issue_category: tech","wait_time:  36.01266<br />call_time: 22.26894<br />issue_category: tech","wait_time:  32.75949<br />call_time: 21.72601<br />issue_category: tech","wait_time:  29.50633<br />call_time: 21.18308<br />issue_category: tech","wait_time:  26.25316<br />call_time: 20.64015<br />issue_category: tech","wait_time:  23.00000<br />call_time: 20.09723<br />issue_category: tech","wait_time:  23.00000<br />call_time: 20.09723<br />issue_category: tech"],"type":"scatter","mode":"lines","line":{"width":3.77952755905512,"color":"transparent","dash":"solid"},"fill":"toself","fillcolor":"rgba(153,153,153,0.4)","hoveron":"points","hoverinfo":"x+y","name":"tech","legendgroup":"tech","showlegend":false,"xaxis":"x","yaxis":"y","frame":null},{"x":[48,51.3670886075949,54.7341772151899,58.1012658227848,61.4683544303797,64.8354430379747,68.2025316455696,71.5696202531646,74.9367088607595,78.3037974683544,81.6708860759494,85.0379746835443,88.4050632911392,91.7721518987342,95.1392405063291,98.5063291139241,101.873417721519,105.240506329114,108.607594936709,111.974683544304,115.341772151899,118.708860759494,122.075949367089,125.443037974684,128.810126582278,132.177215189873,135.544303797468,138.911392405063,142.278481012658,145.645569620253,149.012658227848,152.379746835443,155.746835443038,159.113924050633,162.481012658228,165.848101265823,169.215189873418,172.582278481013,175.949367088608,179.316455696203,182.683544303797,186.050632911392,189.417721518987,192.784810126582,196.151898734177,199.518987341772,202.886075949367,206.253164556962,209.620253164557,212.987341772152,216.354430379747,219.721518987342,223.088607594937,226.455696202532,229.822784810127,233.189873417722,236.556962025316,239.924050632911,243.291139240506,246.658227848101,250.025316455696,253.392405063291,256.759493670886,260.126582278481,263.493670886076,266.860759493671,270.227848101266,273.594936708861,276.962025316456,280.329113924051,283.696202531646,287.063291139241,290.430379746835,293.79746835443,297.164556962025,300.53164556962,303.898734177215,307.26582278481,310.632911392405,314,314,314,310.632911392405,307.26582278481,303.898734177215,300.53164556962,297.164556962025,293.79746835443,290.430379746835,287.063291139241,283.696202531646,280.329113924051,276.962025316456,273.594936708861,270.227848101266,266.860759493671,263.493670886076,260.126582278481,256.759493670886,253.392405063291,250.025316455696,246.658227848101,243.291139240506,239.924050632911,236.556962025316,233.189873417722,229.822784810127,226.455696202532,223.088607594937,219.721518987342,216.354430379747,212.987341772152,209.620253164557,206.253164556962,202.886075949367,199.518987341772,196.151898734177,192.784810126582,189.417721518987,186.050632911392,182.683544303797,179.316455696203,175.949367088608,172.582278481013,169.215189873418,165.848101265823,162.481012658228,159.113924050633,155.746835443038,152.379746835443,149.012658227848,145.645569620253,142.278481012658,138.911392405063,135.544303797468,132.177215189873,128.810126582278,125.443037974684,122.075949367089,118.708860759494,115.341772151899,111.974683544304,108.607594936709,105.240506329114,101.873417721519,98.5063291139241,95.1392405063291,91.7721518987342,88.4050632911392,85.0379746835443,81.6708860759494,78.3037974683544,74.9367088607595,71.5696202531646,68.2025316455696,64.8354430379747,61.4683544303797,58.1012658227848,54.7341772151899,51.3670886075949,48,48],"y":[20.5142545841442,21.1037424568452,21.6926897547152,22.2810598547498,22.8688128921574,23.4559054117921,24.0422899764903,24.6279147265073,25.2127228834607,25.7966521913113,26.3796342859455,26.9615939838779,27.5424484794741,28.1221064389518,28.7004669782775,29.2774185110462,29.8528374516221,30.4265867584212,30.998514302512,31.5684510480862,32.1362090343486,32.7015791537575,33.2643287302978,33.8241989149145,34.3809019349927,34.9341182628356,35.4834938066314,36.0286372785911,36.5691179603649,37.1044641656421,37.6341627912309,38.1576604432674,38.6743667096491,39.1836601990884,39.6848979470371,40.1774286576235,40.6606099686006,41.133829470669,41.5965286005162,42.0482278358382,42.4885509941422,42.9172460624923,43.3342000363175,43.739445806275,44.1331601388294,44.5156530332286,44.88734990549,45.248768874964,45.6004957592294,45.9431592254363,46.2774080345587,46.6038916380474,46.9232447168339,47.236075705232,47.5429589653184,47.8444300673215,48.1409835555765,48.4330725954654,48.7211099654887,49.0054699503593,49.2864907859321,49.564477393573,49.8397042150459,50.112418017903,50.3828405866272,50.6511712483379,50.917589205943,51.1822556683226,51.4453157782837,51.7069003461229,51.967127400835,52.2261035732015,52.4839253258184,52.7406800450732,52.9964470094668,53.2512982477512,53.5052992992576,53.7585098876448,54.010984518158,54.262773007401,54.262773007401,69.0759799885393,68.4885853478227,67.9018768483764,67.315904306804,66.7307222283509,66.1463903366757,65.5629741711098,64.980545760405,64.3991843830624,63.8189774254693,63.2400213502219,62.6624227881015,62.0862997681031,61.5117831005231,60.9390179281687,60.3681654599198,59.7994048986844,59.232935571582,58.6689792630954,58.1077827407767,57.54962044639,56.994797301301,56.4436515413648,55.8965574512941,55.3539278095896,54.8162157816331,54.28391591176,53.7575637701984,53.2377337190254,52.7250341925546,52.2200998717174,51.7235802079648,51.2361239622707,50.7583598017851,50.2908735440869,49.8341833085266,49.3887145111214,48.9547771511194,48.532547994985,48.1220599333756,47.72319996172,47.3357160670825,46.9592320669701,46.593268439079,46.2372666200965,45.8906142007233,45.5526688187125,45.2227791781922,44.9003023146144,44.5846168366913,44.2751323323206,43.9712954076382,43.6725929594524,43.3785533014526,43.0887457152889,42.8027789131722,42.5202988032908,42.240985857948,41.9645523045288,41.6907392939781,41.419314150281,41.1500677658956,40.8828121800269,40.6173783568664,40.3536141674828,40.0913825702919,39.830559979658,39.5710348091762,39.3127061748129,39.0554827427856,38.7992817074604,38.5440278853514,38.2896529123452,38.0360945324026,37.7832959671413,37.5312053568164,37.2797752642645,37.0289622343396,36.7787264022501,36.5290311449914,20.5142545841442],"text":["wait_time:  48.00000<br />call_time: 28.52164<br />issue_category: returns","wait_time:  51.36709<br />call_time: 28.94123<br />issue_category: returns","wait_time:  54.73418<br />call_time: 29.36083<br />issue_category: returns","wait_time:  58.10127<br />call_time: 29.78042<br />issue_category: returns","wait_time:  61.46835<br />call_time: 30.20001<br />issue_category: returns","wait_time:  64.83544<br />call_time: 30.61960<br />issue_category: returns","wait_time:  68.20253<br />call_time: 31.03919<br />issue_category: returns","wait_time:  71.56962<br />call_time: 31.45878<br />issue_category: returns","wait_time:  74.93671<br />call_time: 31.87838<br />issue_category: returns","wait_time:  78.30380<br />call_time: 32.29797<br />issue_category: returns","wait_time:  81.67089<br />call_time: 32.71756<br />issue_category: returns","wait_time:  85.03797<br />call_time: 33.13715<br />issue_category: returns","wait_time:  88.40506<br />call_time: 33.55674<br />issue_category: returns","wait_time:  91.77215<br />call_time: 33.97633<br />issue_category: returns","wait_time:  95.13924<br />call_time: 34.39592<br />issue_category: returns","wait_time:  98.50633<br />call_time: 34.81552<br />issue_category: returns","wait_time: 101.87342<br />call_time: 35.23511<br />issue_category: returns","wait_time: 105.24051<br />call_time: 35.65470<br />issue_category: returns","wait_time: 108.60759<br />call_time: 36.07429<br />issue_category: returns","wait_time: 111.97468<br />call_time: 36.49388<br />issue_category: returns","wait_time: 115.34177<br />call_time: 36.91347<br />issue_category: returns","wait_time: 118.70886<br />call_time: 37.33307<br />issue_category: returns","wait_time: 122.07595<br />call_time: 37.75266<br />issue_category: returns","wait_time: 125.44304<br />call_time: 38.17225<br />issue_category: returns","wait_time: 128.81013<br />call_time: 38.59184<br />issue_category: returns","wait_time: 132.17722<br />call_time: 39.01143<br />issue_category: returns","wait_time: 135.54430<br />call_time: 39.43102<br />issue_category: returns","wait_time: 138.91139<br />call_time: 39.85062<br />issue_category: returns","wait_time: 142.27848<br />call_time: 40.27021<br />issue_category: returns","wait_time: 145.64557<br />call_time: 40.68980<br />issue_category: returns","wait_time: 149.01266<br />call_time: 41.10939<br />issue_category: returns","wait_time: 152.37975<br />call_time: 41.52898<br />issue_category: returns","wait_time: 155.74684<br />call_time: 41.94857<br />issue_category: returns","wait_time: 159.11392<br />call_time: 42.36816<br />issue_category: returns","wait_time: 162.48101<br />call_time: 42.78776<br />issue_category: returns","wait_time: 165.84810<br />call_time: 43.20735<br />issue_category: returns","wait_time: 169.21519<br />call_time: 43.62694<br />issue_category: returns","wait_time: 172.58228<br />call_time: 44.04653<br />issue_category: returns","wait_time: 175.94937<br />call_time: 44.46612<br />issue_category: returns","wait_time: 179.31646<br />call_time: 44.88571<br />issue_category: returns","wait_time: 182.68354<br />call_time: 45.30531<br />issue_category: returns","wait_time: 186.05063<br />call_time: 45.72490<br />issue_category: returns","wait_time: 189.41772<br />call_time: 46.14449<br />issue_category: returns","wait_time: 192.78481<br />call_time: 46.56408<br />issue_category: returns","wait_time: 196.15190<br />call_time: 46.98367<br />issue_category: returns","wait_time: 199.51899<br />call_time: 47.40326<br />issue_category: returns","wait_time: 202.88608<br />call_time: 47.82285<br />issue_category: returns","wait_time: 206.25316<br />call_time: 48.24245<br />issue_category: returns","wait_time: 209.62025<br />call_time: 48.66204<br />issue_category: returns","wait_time: 212.98734<br />call_time: 49.08163<br />issue_category: returns","wait_time: 216.35443<br />call_time: 49.50122<br />issue_category: returns","wait_time: 219.72152<br />call_time: 49.92081<br />issue_category: returns","wait_time: 223.08861<br />call_time: 50.34040<br />issue_category: returns","wait_time: 226.45570<br />call_time: 50.76000<br />issue_category: returns","wait_time: 229.82278<br />call_time: 51.17959<br />issue_category: returns","wait_time: 233.18987<br />call_time: 51.59918<br />issue_category: returns","wait_time: 236.55696<br />call_time: 52.01877<br />issue_category: returns","wait_time: 239.92405<br />call_time: 52.43836<br />issue_category: returns","wait_time: 243.29114<br />call_time: 52.85795<br />issue_category: returns","wait_time: 246.65823<br />call_time: 53.27755<br />issue_category: returns","wait_time: 250.02532<br />call_time: 53.69714<br />issue_category: returns","wait_time: 253.39241<br />call_time: 54.11673<br />issue_category: returns","wait_time: 256.75949<br />call_time: 54.53632<br />issue_category: returns","wait_time: 260.12658<br />call_time: 54.95591<br />issue_category: returns","wait_time: 263.49367<br />call_time: 55.37550<br />issue_category: returns","wait_time: 266.86076<br />call_time: 55.79509<br />issue_category: returns","wait_time: 270.22785<br />call_time: 56.21469<br />issue_category: returns","wait_time: 273.59494<br />call_time: 56.63428<br />issue_category: returns","wait_time: 276.96203<br />call_time: 57.05387<br />issue_category: returns","wait_time: 280.32911<br />call_time: 57.47346<br />issue_category: returns","wait_time: 283.69620<br />call_time: 57.89305<br />issue_category: returns","wait_time: 287.06329<br />call_time: 58.31264<br />issue_category: returns","wait_time: 290.43038<br />call_time: 58.73224<br />issue_category: returns","wait_time: 293.79747<br />call_time: 59.15183<br />issue_category: returns","wait_time: 297.16456<br />call_time: 59.57142<br />issue_category: returns","wait_time: 300.53165<br />call_time: 59.99101<br />issue_category: returns","wait_time: 303.89873<br />call_time: 60.41060<br />issue_category: returns","wait_time: 307.26582<br />call_time: 60.83019<br />issue_category: returns","wait_time: 310.63291<br />call_time: 61.24978<br />issue_category: returns","wait_time: 314.00000<br />call_time: 61.66938<br />issue_category: returns","wait_time: 314.00000<br />call_time: 61.66938<br />issue_category: returns","wait_time: 314.00000<br />call_time: 61.66938<br />issue_category: returns","wait_time: 310.63291<br />call_time: 61.24978<br />issue_category: returns","wait_time: 307.26582<br />call_time: 60.83019<br />issue_category: returns","wait_time: 303.89873<br />call_time: 60.41060<br />issue_category: returns","wait_time: 300.53165<br />call_time: 59.99101<br />issue_category: returns","wait_time: 297.16456<br />call_time: 59.57142<br />issue_category: returns","wait_time: 293.79747<br />call_time: 59.15183<br />issue_category: returns","wait_time: 290.43038<br />call_time: 58.73224<br />issue_category: returns","wait_time: 287.06329<br />call_time: 58.31264<br />issue_category: returns","wait_time: 283.69620<br />call_time: 57.89305<br />issue_category: returns","wait_time: 280.32911<br />call_time: 57.47346<br />issue_category: returns","wait_time: 276.96203<br />call_time: 57.05387<br />issue_category: returns","wait_time: 273.59494<br />call_time: 56.63428<br />issue_category: returns","wait_time: 270.22785<br />call_time: 56.21469<br />issue_category: returns","wait_time: 266.86076<br />call_time: 55.79509<br />issue_category: returns","wait_time: 263.49367<br />call_time: 55.37550<br />issue_category: returns","wait_time: 260.12658<br />call_time: 54.95591<br />issue_category: returns","wait_time: 256.75949<br />call_time: 54.53632<br />issue_category: returns","wait_time: 253.39241<br />call_time: 54.11673<br />issue_category: returns","wait_time: 250.02532<br />call_time: 53.69714<br />issue_category: returns","wait_time: 246.65823<br />call_time: 53.27755<br />issue_category: returns","wait_time: 243.29114<br />call_time: 52.85795<br />issue_category: returns","wait_time: 239.92405<br />call_time: 52.43836<br />issue_category: returns","wait_time: 236.55696<br />call_time: 52.01877<br />issue_category: returns","wait_time: 233.18987<br />call_time: 51.59918<br />issue_category: returns","wait_time: 229.82278<br />call_time: 51.17959<br />issue_category: returns","wait_time: 226.45570<br />call_time: 50.76000<br />issue_category: returns","wait_time: 223.08861<br />call_time: 50.34040<br />issue_category: returns","wait_time: 219.72152<br />call_time: 49.92081<br />issue_category: returns","wait_time: 216.35443<br />call_time: 49.50122<br />issue_category: returns","wait_time: 212.98734<br />call_time: 49.08163<br />issue_category: returns","wait_time: 209.62025<br />call_time: 48.66204<br />issue_category: returns","wait_time: 206.25316<br />call_time: 48.24245<br />issue_category: returns","wait_time: 202.88608<br />call_time: 47.82285<br />issue_category: returns","wait_time: 199.51899<br />call_time: 47.40326<br />issue_category: returns","wait_time: 196.15190<br />call_time: 46.98367<br />issue_category: returns","wait_time: 192.78481<br />call_time: 46.56408<br />issue_category: returns","wait_time: 189.41772<br />call_time: 46.14449<br />issue_category: returns","wait_time: 186.05063<br />call_time: 45.72490<br />issue_category: returns","wait_time: 182.68354<br />call_time: 45.30531<br />issue_category: returns","wait_time: 179.31646<br />call_time: 44.88571<br />issue_category: returns","wait_time: 175.94937<br />call_time: 44.46612<br />issue_category: returns","wait_time: 172.58228<br />call_time: 44.04653<br />issue_category: returns","wait_time: 169.21519<br />call_time: 43.62694<br />issue_category: returns","wait_time: 165.84810<br />call_time: 43.20735<br />issue_category: returns","wait_time: 162.48101<br />call_time: 42.78776<br />issue_category: returns","wait_time: 159.11392<br />call_time: 42.36816<br />issue_category: returns","wait_time: 155.74684<br />call_time: 41.94857<br />issue_category: returns","wait_time: 152.37975<br />call_time: 41.52898<br />issue_category: returns","wait_time: 149.01266<br />call_time: 41.10939<br />issue_category: returns","wait_time: 145.64557<br />call_time: 40.68980<br />issue_category: returns","wait_time: 142.27848<br />call_time: 40.27021<br />issue_category: returns","wait_time: 138.91139<br />call_time: 39.85062<br />issue_category: returns","wait_time: 135.54430<br />call_time: 39.43102<br />issue_category: returns","wait_time: 132.17722<br />call_time: 39.01143<br />issue_category: returns","wait_time: 128.81013<br />call_time: 38.59184<br />issue_category: returns","wait_time: 125.44304<br />call_time: 38.17225<br />issue_category: returns","wait_time: 122.07595<br />call_time: 37.75266<br />issue_category: returns","wait_time: 118.70886<br />call_time: 37.33307<br />issue_category: returns","wait_time: 115.34177<br />call_time: 36.91347<br />issue_category: returns","wait_time: 111.97468<br />call_time: 36.49388<br />issue_category: returns","wait_time: 108.60759<br />call_time: 36.07429<br />issue_category: returns","wait_time: 105.24051<br />call_time: 35.65470<br />issue_category: returns","wait_time: 101.87342<br />call_time: 35.23511<br />issue_category: returns","wait_time:  98.50633<br />call_time: 34.81552<br />issue_category: returns","wait_time:  95.13924<br />call_time: 34.39592<br />issue_category: returns","wait_time:  91.77215<br />call_time: 33.97633<br />issue_category: returns","wait_time:  88.40506<br />call_time: 33.55674<br />issue_category: returns","wait_time:  85.03797<br />call_time: 33.13715<br />issue_category: returns","wait_time:  81.67089<br />call_time: 32.71756<br />issue_category: returns","wait_time:  78.30380<br />call_time: 32.29797<br />issue_category: returns","wait_time:  74.93671<br />call_time: 31.87838<br />issue_category: returns","wait_time:  71.56962<br />call_time: 31.45878<br />issue_category: returns","wait_time:  68.20253<br />call_time: 31.03919<br />issue_category: returns","wait_time:  64.83544<br />call_time: 30.61960<br />issue_category: returns","wait_time:  61.46835<br />call_time: 30.20001<br />issue_category: returns","wait_time:  58.10127<br />call_time: 29.78042<br />issue_category: returns","wait_time:  54.73418<br />call_time: 29.36083<br />issue_category: returns","wait_time:  51.36709<br />call_time: 28.94123<br />issue_category: returns","wait_time:  48.00000<br />call_time: 28.52164<br />issue_category: returns","wait_time:  48.00000<br />call_time: 28.52164<br />issue_category: returns"],"type":"scatter","mode":"lines","line":{"width":3.77952755905512,"color":"transparent","dash":"solid"},"fill":"toself","fillcolor":"rgba(153,153,153,0.4)","hoveron":"points","hoverinfo":"x+y","name":"returns","legendgroup":"returns","showlegend":false,"xaxis":"x","yaxis":"y","frame":null},{"x":[58,60.6455696202532,63.2911392405063,65.9367088607595,68.5822784810127,71.2278481012658,73.873417721519,76.5189873417721,79.1645569620253,81.8101265822785,84.4556962025316,87.1012658227848,89.746835443038,92.3924050632911,95.0379746835443,97.6835443037975,100.329113924051,102.974683544304,105.620253164557,108.26582278481,110.911392405063,113.556962025316,116.20253164557,118.848101265823,121.493670886076,124.139240506329,126.784810126582,129.430379746835,132.075949367089,134.721518987342,137.367088607595,140.012658227848,142.658227848101,145.303797468354,147.949367088608,150.594936708861,153.240506329114,155.886075949367,158.53164556962,161.177215189873,163.822784810127,166.46835443038,169.113924050633,171.759493670886,174.405063291139,177.050632911392,179.696202531646,182.341772151899,184.987341772152,187.632911392405,190.278481012658,192.924050632911,195.569620253165,198.215189873418,200.860759493671,203.506329113924,206.151898734177,208.79746835443,211.443037974684,214.088607594937,216.73417721519,219.379746835443,222.025316455696,224.670886075949,227.316455696203,229.962025316456,232.607594936709,235.253164556962,237.898734177215,240.544303797468,243.189873417722,245.835443037975,248.481012658228,251.126582278481,253.772151898734,256.417721518987,259.063291139241,261.708860759494,264.354430379747,267,267,264.354430379747,261.708860759494,259.063291139241,256.417721518987,253.772151898734,251.126582278481,248.481012658228,245.835443037975,243.189873417722,240.544303797468,237.898734177215,235.253164556962,232.607594936709,229.962025316456,227.316455696203,224.670886075949,222.025316455696,219.379746835443,216.73417721519,214.088607594937,211.443037974684,208.79746835443,206.151898734177,203.506329113924,200.860759493671,198.215189873418,195.569620253165,192.924050632911,190.278481012658,187.632911392405,184.987341772152,182.341772151899,179.696202531646,177.050632911392,174.405063291139,171.759493670886,169.113924050633,166.46835443038,163.822784810127,161.177215189873,158.53164556962,155.886075949367,153.240506329114,150.594936708861,147.949367088608,145.303797468354,142.658227848101,140.012658227848,137.367088607595,134.721518987342,132.075949367089,129.430379746835,126.784810126582,124.139240506329,121.493670886076,118.848101265823,116.20253164557,113.556962025316,110.911392405063,108.26582278481,105.620253164557,102.974683544304,100.329113924051,97.6835443037975,95.0379746835443,92.3924050632911,89.746835443038,87.1012658227848,84.4556962025316,81.8101265822785,79.1645569620253,76.5189873417721,73.873417721519,71.2278481012658,68.5822784810127,65.9367088607595,63.2911392405063,60.6455696202532,58,58],"y":[18.2993665377153,18.8821126146464,19.4642471095725,20.0457352779674,20.6265398058851,21.2066205799311,21.7859344336209,22.3644348674885,22.9420717400134,23.5187909261056,24.0945339395371,24.6692375153249,25.242833147665,25.81524657859,26.3863972320863,26.9561975879688,27.5245524893995,28.0913583775701,28.6565024467983,29.2198617131566,29.781301989854,30.3406767630091,30.8978259623386,31.4525746228126,32.0047314357198,32.5540871911485,33.1004131189719,33.6434591424727,34.1829520682702,34.7185937487967,35.2500592698069,35.7769952358651,36.2990182518334,36.8157137281303,37.3266351713944,37.8313041586264,38.3292112289515,38.8198179580226,39.3025604986948,39.77685486855,40.2421042289453,40.6977083199334,41.1430750814185,41.5776343001657,42.0008528823645,42.412251084451,42.8114187786087,43.1980306336842,43.5718590096271,43.9327834347718,44.2807957743908,44.6160005835313,44.9386106090021,45.2489378833945,45.5473812554373,45.8344114632622,46.1105549523882,46.3763775776558,46.6324691457629,46.8794295042126,47.1178566143525,47.3483368006478,47.571437169756,47.7877000508302,47.9976392209186,48.2017376377388,48.400446395057,48.5941846320306,48.7833401574792,48.9682705857223,49.1493048172242,49.3267447316445,49.5008669912853,49.6719248786787,49.840150113166,50.0057546081291,50.1689321436083,50.3298599389672,50.4887001176368,50.6456010613091,67.6261562242183,67.0630638865517,66.5019107838823,65.9428452979022,65.3860295520424,64.8316407656666,64.2798727188149,63.7309373248693,63.1850663031711,62.6425129362525,62.1035538864153,61.5684910333195,61.0376532774292,60.5113982330637,59.990113709043,59.4742188445242,58.9641647332736,58.4604343330088,57.9635414207781,57.4740283257343,56.9924621545353,56.519429231646,56.0555275184141,55.6013568623427,55.1575070701297,54.7245439966156,54.3029940873195,53.8933280803729,53.4959448245047,53.1111563523062,52.7391754105863,52.380106554392,52.0339416489959,51.7005602227325,51.3797346355512,51.0711395562987,50.7743648571585,50.4889307945667,50.2143042747128,49.949915084362,49.6951711634183,49.4494722519345,49.2122215112677,48.9828349589998,48.7607487479859,48.545424453879,48.3363526158042,48.133054810762,47.9350845453913,47.7420272301106,47.5534994697818,47.3691478689693,47.1886475134278,47.0117002555896,46.8380329020741,46.6673953761638,46.499558907732,46.334314286867,46.1714702048576,46.0108516966736,45.8522986920321,45.6956646770514,45.5408154649406,45.3876280717723,45.235989691864,45.0857967664075,44.9369541385648,44.7893742881509,44.6429766391519,44.4976869336008,44.3534366656933,44.2101625704466,44.0678061616325,43.9263133141611,43.7856338865119,43.6457213792189,43.5065326257976,43.3680275128535,43.2301687264407,43.0929215220328,18.2993665377153],"text":["wait_time:  58.00000<br />call_time: 30.69614<br />issue_category: sales","wait_time:  60.64557<br />call_time: 31.05614<br />issue_category: sales","wait_time:  63.29114<br />call_time: 31.41614<br />issue_category: sales","wait_time:  65.93671<br />call_time: 31.77613<br />issue_category: sales","wait_time:  68.58228<br />call_time: 32.13613<br />issue_category: sales","wait_time:  71.22785<br />call_time: 32.49613<br />issue_category: sales","wait_time:  73.87342<br />call_time: 32.85612<br />issue_category: sales","wait_time:  76.51899<br />call_time: 33.21612<br />issue_category: sales","wait_time:  79.16456<br />call_time: 33.57612<br />issue_category: sales","wait_time:  81.81013<br />call_time: 33.93611<br />issue_category: sales","wait_time:  84.45570<br />call_time: 34.29611<br />issue_category: sales","wait_time:  87.10127<br />call_time: 34.65611<br />issue_category: sales","wait_time:  89.74684<br />call_time: 35.01610<br />issue_category: sales","wait_time:  92.39241<br />call_time: 35.37610<br />issue_category: sales","wait_time:  95.03797<br />call_time: 35.73610<br />issue_category: sales","wait_time:  97.68354<br />call_time: 36.09609<br />issue_category: sales","wait_time: 100.32911<br />call_time: 36.45609<br />issue_category: sales","wait_time: 102.97468<br />call_time: 36.81609<br />issue_category: sales","wait_time: 105.62025<br />call_time: 37.17608<br />issue_category: sales","wait_time: 108.26582<br />call_time: 37.53608<br />issue_category: sales","wait_time: 110.91139<br />call_time: 37.89608<br />issue_category: sales","wait_time: 113.55696<br />call_time: 38.25607<br />issue_category: sales","wait_time: 116.20253<br />call_time: 38.61607<br />issue_category: sales","wait_time: 118.84810<br />call_time: 38.97607<br />issue_category: sales","wait_time: 121.49367<br />call_time: 39.33606<br />issue_category: sales","wait_time: 124.13924<br />call_time: 39.69606<br />issue_category: sales","wait_time: 126.78481<br />call_time: 40.05606<br />issue_category: sales","wait_time: 129.43038<br />call_time: 40.41605<br />issue_category: sales","wait_time: 132.07595<br />call_time: 40.77605<br />issue_category: sales","wait_time: 134.72152<br />call_time: 41.13605<br />issue_category: sales","wait_time: 137.36709<br />call_time: 41.49604<br />issue_category: sales","wait_time: 140.01266<br />call_time: 41.85604<br />issue_category: sales","wait_time: 142.65823<br />call_time: 42.21604<br />issue_category: sales","wait_time: 145.30380<br />call_time: 42.57603<br />issue_category: sales","wait_time: 147.94937<br />call_time: 42.93603<br />issue_category: sales","wait_time: 150.59494<br />call_time: 43.29603<br />issue_category: sales","wait_time: 153.24051<br />call_time: 43.65602<br />issue_category: sales","wait_time: 155.88608<br />call_time: 44.01602<br />issue_category: sales","wait_time: 158.53165<br />call_time: 44.37602<br />issue_category: sales","wait_time: 161.17722<br />call_time: 44.73601<br />issue_category: sales","wait_time: 163.82278<br />call_time: 45.09601<br />issue_category: sales","wait_time: 166.46835<br />call_time: 45.45601<br />issue_category: sales","wait_time: 169.11392<br />call_time: 45.81600<br />issue_category: sales","wait_time: 171.75949<br />call_time: 46.17600<br />issue_category: sales","wait_time: 174.40506<br />call_time: 46.53600<br />issue_category: sales","wait_time: 177.05063<br />call_time: 46.89599<br />issue_category: sales","wait_time: 179.69620<br />call_time: 47.25599<br />issue_category: sales","wait_time: 182.34177<br />call_time: 47.61599<br />issue_category: sales","wait_time: 184.98734<br />call_time: 47.97598<br />issue_category: sales","wait_time: 187.63291<br />call_time: 48.33598<br />issue_category: sales","wait_time: 190.27848<br />call_time: 48.69598<br />issue_category: sales","wait_time: 192.92405<br />call_time: 49.05597<br />issue_category: sales","wait_time: 195.56962<br />call_time: 49.41597<br />issue_category: sales","wait_time: 198.21519<br />call_time: 49.77597<br />issue_category: sales","wait_time: 200.86076<br />call_time: 50.13596<br />issue_category: sales","wait_time: 203.50633<br />call_time: 50.49596<br />issue_category: sales","wait_time: 206.15190<br />call_time: 50.85596<br />issue_category: sales","wait_time: 208.79747<br />call_time: 51.21595<br />issue_category: sales","wait_time: 211.44304<br />call_time: 51.57595<br />issue_category: sales","wait_time: 214.08861<br />call_time: 51.93595<br />issue_category: sales","wait_time: 216.73418<br />call_time: 52.29594<br />issue_category: sales","wait_time: 219.37975<br />call_time: 52.65594<br />issue_category: sales","wait_time: 222.02532<br />call_time: 53.01594<br />issue_category: sales","wait_time: 224.67089<br />call_time: 53.37593<br />issue_category: sales","wait_time: 227.31646<br />call_time: 53.73593<br />issue_category: sales","wait_time: 229.96203<br />call_time: 54.09593<br />issue_category: sales","wait_time: 232.60759<br />call_time: 54.45592<br />issue_category: sales","wait_time: 235.25316<br />call_time: 54.81592<br />issue_category: sales","wait_time: 237.89873<br />call_time: 55.17592<br />issue_category: sales","wait_time: 240.54430<br />call_time: 55.53591<br />issue_category: sales","wait_time: 243.18987<br />call_time: 55.89591<br />issue_category: sales","wait_time: 245.83544<br />call_time: 56.25591<br />issue_category: sales","wait_time: 248.48101<br />call_time: 56.61590<br />issue_category: sales","wait_time: 251.12658<br />call_time: 56.97590<br />issue_category: sales","wait_time: 253.77215<br />call_time: 57.33590<br />issue_category: sales","wait_time: 256.41772<br />call_time: 57.69589<br />issue_category: sales","wait_time: 259.06329<br />call_time: 58.05589<br />issue_category: sales","wait_time: 261.70886<br />call_time: 58.41589<br />issue_category: sales","wait_time: 264.35443<br />call_time: 58.77588<br />issue_category: sales","wait_time: 267.00000<br />call_time: 59.13588<br />issue_category: sales","wait_time: 267.00000<br />call_time: 59.13588<br />issue_category: sales","wait_time: 264.35443<br />call_time: 58.77588<br />issue_category: sales","wait_time: 261.70886<br />call_time: 58.41589<br />issue_category: sales","wait_time: 259.06329<br />call_time: 58.05589<br />issue_category: sales","wait_time: 256.41772<br />call_time: 57.69589<br />issue_category: sales","wait_time: 253.77215<br />call_time: 57.33590<br />issue_category: sales","wait_time: 251.12658<br />call_time: 56.97590<br />issue_category: sales","wait_time: 248.48101<br />call_time: 56.61590<br />issue_category: sales","wait_time: 245.83544<br />call_time: 56.25591<br />issue_category: sales","wait_time: 243.18987<br />call_time: 55.89591<br />issue_category: sales","wait_time: 240.54430<br />call_time: 55.53591<br />issue_category: sales","wait_time: 237.89873<br />call_time: 55.17592<br />issue_category: sales","wait_time: 235.25316<br />call_time: 54.81592<br />issue_category: sales","wait_time: 232.60759<br />call_time: 54.45592<br />issue_category: sales","wait_time: 229.96203<br />call_time: 54.09593<br />issue_category: sales","wait_time: 227.31646<br />call_time: 53.73593<br />issue_category: sales","wait_time: 224.67089<br />call_time: 53.37593<br />issue_category: sales","wait_time: 222.02532<br />call_time: 53.01594<br />issue_category: sales","wait_time: 219.37975<br />call_time: 52.65594<br />issue_category: sales","wait_time: 216.73418<br />call_time: 52.29594<br />issue_category: sales","wait_time: 214.08861<br />call_time: 51.93595<br />issue_category: sales","wait_time: 211.44304<br />call_time: 51.57595<br />issue_category: sales","wait_time: 208.79747<br />call_time: 51.21595<br />issue_category: sales","wait_time: 206.15190<br />call_time: 50.85596<br />issue_category: sales","wait_time: 203.50633<br />call_time: 50.49596<br />issue_category: sales","wait_time: 200.86076<br />call_time: 50.13596<br />issue_category: sales","wait_time: 198.21519<br />call_time: 49.77597<br />issue_category: sales","wait_time: 195.56962<br />call_time: 49.41597<br />issue_category: sales","wait_time: 192.92405<br />call_time: 49.05597<br />issue_category: sales","wait_time: 190.27848<br />call_time: 48.69598<br />issue_category: sales","wait_time: 187.63291<br />call_time: 48.33598<br />issue_category: sales","wait_time: 184.98734<br />call_time: 47.97598<br />issue_category: sales","wait_time: 182.34177<br />call_time: 47.61599<br />issue_category: sales","wait_time: 179.69620<br />call_time: 47.25599<br />issue_category: sales","wait_time: 177.05063<br />call_time: 46.89599<br />issue_category: sales","wait_time: 174.40506<br />call_time: 46.53600<br />issue_category: sales","wait_time: 171.75949<br />call_time: 46.17600<br />issue_category: sales","wait_time: 169.11392<br />call_time: 45.81600<br />issue_category: sales","wait_time: 166.46835<br />call_time: 45.45601<br />issue_category: sales","wait_time: 163.82278<br />call_time: 45.09601<br />issue_category: sales","wait_time: 161.17722<br />call_time: 44.73601<br />issue_category: sales","wait_time: 158.53165<br />call_time: 44.37602<br />issue_category: sales","wait_time: 155.88608<br />call_time: 44.01602<br />issue_category: sales","wait_time: 153.24051<br />call_time: 43.65602<br />issue_category: sales","wait_time: 150.59494<br />call_time: 43.29603<br />issue_category: sales","wait_time: 147.94937<br />call_time: 42.93603<br />issue_category: sales","wait_time: 145.30380<br />call_time: 42.57603<br />issue_category: sales","wait_time: 142.65823<br />call_time: 42.21604<br />issue_category: sales","wait_time: 140.01266<br />call_time: 41.85604<br />issue_category: sales","wait_time: 137.36709<br />call_time: 41.49604<br />issue_category: sales","wait_time: 134.72152<br />call_time: 41.13605<br />issue_category: sales","wait_time: 132.07595<br />call_time: 40.77605<br />issue_category: sales","wait_time: 129.43038<br />call_time: 40.41605<br />issue_category: sales","wait_time: 126.78481<br />call_time: 40.05606<br />issue_category: sales","wait_time: 124.13924<br />call_time: 39.69606<br />issue_category: sales","wait_time: 121.49367<br />call_time: 39.33606<br />issue_category: sales","wait_time: 118.84810<br />call_time: 38.97607<br />issue_category: sales","wait_time: 116.20253<br />call_time: 38.61607<br />issue_category: sales","wait_time: 113.55696<br />call_time: 38.25607<br />issue_category: sales","wait_time: 110.91139<br />call_time: 37.89608<br />issue_category: sales","wait_time: 108.26582<br />call_time: 37.53608<br />issue_category: sales","wait_time: 105.62025<br />call_time: 37.17608<br />issue_category: sales","wait_time: 102.97468<br />call_time: 36.81609<br />issue_category: sales","wait_time: 100.32911<br />call_time: 36.45609<br />issue_category: sales","wait_time:  97.68354<br />call_time: 36.09609<br />issue_category: sales","wait_time:  95.03797<br />call_time: 35.73610<br />issue_category: sales","wait_time:  92.39241<br />call_time: 35.37610<br />issue_category: sales","wait_time:  89.74684<br />call_time: 35.01610<br />issue_category: sales","wait_time:  87.10127<br />call_time: 34.65611<br />issue_category: sales","wait_time:  84.45570<br />call_time: 34.29611<br />issue_category: sales","wait_time:  81.81013<br />call_time: 33.93611<br />issue_category: sales","wait_time:  79.16456<br />call_time: 33.57612<br />issue_category: sales","wait_time:  76.51899<br />call_time: 33.21612<br />issue_category: sales","wait_time:  73.87342<br />call_time: 32.85612<br />issue_category: sales","wait_time:  71.22785<br />call_time: 32.49613<br />issue_category: sales","wait_time:  68.58228<br />call_time: 32.13613<br />issue_category: sales","wait_time:  65.93671<br />call_time: 31.77613<br />issue_category: sales","wait_time:  63.29114<br />call_time: 31.41614<br />issue_category: sales","wait_time:  60.64557<br />call_time: 31.05614<br />issue_category: sales","wait_time:  58.00000<br />call_time: 30.69614<br />issue_category: sales","wait_time:  58.00000<br />call_time: 30.69614<br />issue_category: sales"],"type":"scatter","mode":"lines","line":{"width":3.77952755905512,"color":"transparent","dash":"solid"},"fill":"toself","fillcolor":"rgba(153,153,153,0.4)","hoveron":"points","hoverinfo":"x+y","name":"sales","legendgroup":"sales","showlegend":false,"xaxis":"x","yaxis":"y","frame":null},{"x":[39,41.9493670886076,44.8987341772152,47.8481012658228,50.7974683544304,53.746835443038,56.6962025316456,59.6455696202532,62.5949367088608,65.5443037974684,68.4936708860759,71.4430379746835,74.3924050632911,77.3417721518987,80.2911392405063,83.2405063291139,86.1898734177215,89.1392405063291,92.0886075949367,95.0379746835443,97.9873417721519,100.936708860759,103.886075949367,106.835443037975,109.784810126582,112.73417721519,115.683544303797,118.632911392405,121.582278481013,124.53164556962,127.481012658228,130.430379746835,133.379746835443,136.329113924051,139.278481012658,142.227848101266,145.177215189873,148.126582278481,151.075949367089,154.025316455696,156.974683544304,159.924050632911,162.873417721519,165.822784810127,168.772151898734,171.721518987342,174.670886075949,177.620253164557,180.569620253165,183.518987341772,186.46835443038,189.417721518987,192.367088607595,195.316455696203,198.26582278481,201.215189873418,204.164556962025,207.113924050633,210.063291139241,213.012658227848,215.962025316456,218.911392405063,221.860759493671,224.810126582278,227.759493670886,230.708860759494,233.658227848101,236.607594936709,239.556962025316,242.506329113924,245.455696202532,248.405063291139,251.354430379747,254.303797468354,257.253164556962,260.20253164557,263.151898734177,266.101265822785,269.050632911392,272,272,269.050632911392,266.101265822785,263.151898734177,260.20253164557,257.253164556962,254.303797468354,251.354430379747,248.405063291139,245.455696202532,242.506329113924,239.556962025316,236.607594936709,233.658227848101,230.708860759494,227.759493670886,224.810126582278,221.860759493671,218.911392405063,215.962025316456,213.012658227848,210.063291139241,207.113924050633,204.164556962025,201.215189873418,198.26582278481,195.316455696203,192.367088607595,189.417721518987,186.46835443038,183.518987341772,180.569620253165,177.620253164557,174.670886075949,171.721518987342,168.772151898734,165.822784810127,162.873417721519,159.924050632911,156.974683544304,154.025316455696,151.075949367089,148.126582278481,145.177215189873,142.227848101266,139.278481012658,136.329113924051,133.379746835443,130.430379746835,127.481012658228,124.53164556962,121.582278481013,118.632911392405,115.683544303797,112.73417721519,109.784810126582,106.835443037975,103.886075949367,100.936708860759,97.9873417721519,95.0379746835443,92.0886075949367,89.1392405063291,86.1898734177215,83.2405063291139,80.2911392405063,77.3417721518987,74.3924050632911,71.4430379746835,68.4936708860759,65.5443037974684,62.5949367088608,59.6455696202532,56.6962025316456,53.746835443038,50.7974683544304,47.8481012658228,44.8987341772152,41.9493670886076,39,39],"y":[0.0783497259996331,1.0277336464001,1.97651907799963,2.92467155908148,3.87215399693947,4.81892641895732,5.76494569579506,6.71016523310739,7.65453462771164,8.59799928353776,9.54049998201852,10.4819724008018,11.4223465737708,12.3615462843288,13.2994883827179,14.2360820167815,15.1712277640206,16.1048166510152,17.0367290442574,17.9668333941627,18.8949848114668,19.821023452386,20.7447726858356,21.6660370127187,22.584599703915,23.5002201202959,24.4126306751575,25.3215333973379,26.2265960526495,27.1274477831019,28.0236742291453,28.9148121118398,29.8003432722282,30.6796881979659,31.5521991172461,32.4171528132021,33.2737434151287,34.1210755631607,34.9581585262404,35.7839020809365,36.5971152237233,37.3965090690062,38.180705533049,38.9482535422749,39.6976544218315,40.4273976827425,41.1360075096293,41.8220988025917,42.4844397420033,43.1220158324568,43.7340887601656,44.3202427742176,44.8804121388352,45.4148855626859,45.9242869262565,46.4095352245174,46.8717894716893,47.3123857333381,47.73277332826,48.1344559198012,48.5189412787591,48.8877015199091,49.2421439833904,49.5835918196891,49.913272735078,50.232314156937,50.5417431498222,50.8424896315064,51.1353917130822,51.4212022613859,51.7005960249784,51.9741768647029,52.2424847854189,52.5060025815671,52.7651619925994,53.0203493220816,53.2719105127802,53.5201556945011,53.7653632359632,54.0077833396575,78.4941491211646,77.5738546163101,76.6563475492235,75.7418781223957,74.8307247045456,73.9231974254791,73.0196422279626,72.1204454155621,71.2260387277294,70.3369049589052,69.453584113949,68.576680053704,67.7068675267311,66.8448993998665,65.9916137842031,65.1479405975133,64.3149069043535,63.4936401321035,62.6853679870361,61.8914136196374,61.1131843700465,60.3521523530391,59.6098253394122,58.8877069925123,58.1872466311355,57.5097803208477,56.8564670758696,56.2282258911716,55.6256806472405,55.0491200527437,54.4984783719038,53.9733398538086,53.4729661846715,52.9963428690852,52.5422380874233,52.1092667397855,51.6959530107934,51.3007864114706,50.9222682669646,50.5589475036988,50.209446037937,49.8724749840844,49.5468433386153,49.2314608780986,48.9253368714765,48.6275759588838,48.3373722696153,48.0540025868042,47.7768191386439,47.5052424127897,47.2387542502844,46.9768913721881,46.719239418951,46.4654275325827,46.2151234788955,45.9680292867277,45.7238773693753,45.4824270877097,45.2434617126106,45.0067857449811,44.7722225537365,44.5396122950931,44.3088100797865,44.0796843582324,43.8521154969228,43.6259945224376,43.401222012278,43.1777071142874,42.9553666787077,42.7341244889422,42.5139105788743,42.2946606261517,42.0763154122072,41.8588203409708,41.6421250092598,41.426182822729,41.2109506520382,40.9963885245714,40.7824593476222,40.5691286594739,0.0783497259996331],"text":["wait_time:  39.00000<br />call_time: 20.32374<br />issue_category: other","wait_time:  41.94937<br />call_time: 20.90510<br />issue_category: other","wait_time:  44.89873<br />call_time: 21.48645<br />issue_category: other","wait_time:  47.84810<br />call_time: 22.06781<br />issue_category: other","wait_time:  50.79747<br />call_time: 22.64917<br />issue_category: other","wait_time:  53.74684<br />call_time: 23.23053<br />issue_category: other","wait_time:  56.69620<br />call_time: 23.81188<br />issue_category: other","wait_time:  59.64557<br />call_time: 24.39324<br />issue_category: other","wait_time:  62.59494<br />call_time: 24.97460<br />issue_category: other","wait_time:  65.54430<br />call_time: 25.55595<br />issue_category: other","wait_time:  68.49367<br />call_time: 26.13731<br />issue_category: other","wait_time:  71.44304<br />call_time: 26.71867<br />issue_category: other","wait_time:  74.39241<br />call_time: 27.30003<br />issue_category: other","wait_time:  77.34177<br />call_time: 27.88138<br />issue_category: other","wait_time:  80.29114<br />call_time: 28.46274<br />issue_category: other","wait_time:  83.24051<br />call_time: 29.04410<br />issue_category: other","wait_time:  86.18987<br />call_time: 29.62546<br />issue_category: other","wait_time:  89.13924<br />call_time: 30.20681<br />issue_category: other","wait_time:  92.08861<br />call_time: 30.78817<br />issue_category: other","wait_time:  95.03797<br />call_time: 31.36953<br />issue_category: other","wait_time:  97.98734<br />call_time: 31.95089<br />issue_category: other","wait_time: 100.93671<br />call_time: 32.53224<br />issue_category: other","wait_time: 103.88608<br />call_time: 33.11360<br />issue_category: other","wait_time: 106.83544<br />call_time: 33.69496<br />issue_category: other","wait_time: 109.78481<br />call_time: 34.27631<br />issue_category: other","wait_time: 112.73418<br />call_time: 34.85767<br />issue_category: other","wait_time: 115.68354<br />call_time: 35.43903<br />issue_category: other","wait_time: 118.63291<br />call_time: 36.02039<br />issue_category: other","wait_time: 121.58228<br />call_time: 36.60174<br />issue_category: other","wait_time: 124.53165<br />call_time: 37.18310<br />issue_category: other","wait_time: 127.48101<br />call_time: 37.76446<br />issue_category: other","wait_time: 130.43038<br />call_time: 38.34582<br />issue_category: other","wait_time: 133.37975<br />call_time: 38.92717<br />issue_category: other","wait_time: 136.32911<br />call_time: 39.50853<br />issue_category: other","wait_time: 139.27848<br />call_time: 40.08989<br />issue_category: other","wait_time: 142.22785<br />call_time: 40.67124<br />issue_category: other","wait_time: 145.17722<br />call_time: 41.25260<br />issue_category: other","wait_time: 148.12658<br />call_time: 41.83396<br />issue_category: other","wait_time: 151.07595<br />call_time: 42.41532<br />issue_category: other","wait_time: 154.02532<br />call_time: 42.99667<br />issue_category: other","wait_time: 156.97468<br />call_time: 43.57803<br />issue_category: other","wait_time: 159.92405<br />call_time: 44.15939<br />issue_category: other","wait_time: 162.87342<br />call_time: 44.74075<br />issue_category: other","wait_time: 165.82278<br />call_time: 45.32210<br />issue_category: other","wait_time: 168.77215<br />call_time: 45.90346<br />issue_category: other","wait_time: 171.72152<br />call_time: 46.48482<br />issue_category: other","wait_time: 174.67089<br />call_time: 47.06618<br />issue_category: other","wait_time: 177.62025<br />call_time: 47.64753<br />issue_category: other","wait_time: 180.56962<br />call_time: 48.22889<br />issue_category: other","wait_time: 183.51899<br />call_time: 48.81025<br />issue_category: other","wait_time: 186.46835<br />call_time: 49.39160<br />issue_category: other","wait_time: 189.41772<br />call_time: 49.97296<br />issue_category: other","wait_time: 192.36709<br />call_time: 50.55432<br />issue_category: other","wait_time: 195.31646<br />call_time: 51.13568<br />issue_category: other","wait_time: 198.26582<br />call_time: 51.71703<br />issue_category: other","wait_time: 201.21519<br />call_time: 52.29839<br />issue_category: other","wait_time: 204.16456<br />call_time: 52.87975<br />issue_category: other","wait_time: 207.11392<br />call_time: 53.46111<br />issue_category: other","wait_time: 210.06329<br />call_time: 54.04246<br />issue_category: other","wait_time: 213.01266<br />call_time: 54.62382<br />issue_category: other","wait_time: 215.96203<br />call_time: 55.20518<br />issue_category: other","wait_time: 218.91139<br />call_time: 55.78653<br />issue_category: other","wait_time: 221.86076<br />call_time: 56.36789<br />issue_category: other","wait_time: 224.81013<br />call_time: 56.94925<br />issue_category: other","wait_time: 227.75949<br />call_time: 57.53061<br />issue_category: other","wait_time: 230.70886<br />call_time: 58.11196<br />issue_category: other","wait_time: 233.65823<br />call_time: 58.69332<br />issue_category: other","wait_time: 236.60759<br />call_time: 59.27468<br />issue_category: other","wait_time: 239.55696<br />call_time: 59.85604<br />issue_category: other","wait_time: 242.50633<br />call_time: 60.43739<br />issue_category: other","wait_time: 245.45570<br />call_time: 61.01875<br />issue_category: other","wait_time: 248.40506<br />call_time: 61.60011<br />issue_category: other","wait_time: 251.35443<br />call_time: 62.18147<br />issue_category: other","wait_time: 254.30380<br />call_time: 62.76282<br />issue_category: other","wait_time: 257.25316<br />call_time: 63.34418<br />issue_category: other","wait_time: 260.20253<br />call_time: 63.92554<br />issue_category: other","wait_time: 263.15190<br />call_time: 64.50689<br />issue_category: other","wait_time: 266.10127<br />call_time: 65.08825<br />issue_category: other","wait_time: 269.05063<br />call_time: 65.66961<br />issue_category: other","wait_time: 272.00000<br />call_time: 66.25097<br />issue_category: other","wait_time: 272.00000<br />call_time: 66.25097<br />issue_category: other","wait_time: 269.05063<br />call_time: 65.66961<br />issue_category: other","wait_time: 266.10127<br />call_time: 65.08825<br />issue_category: other","wait_time: 263.15190<br />call_time: 64.50689<br />issue_category: other","wait_time: 260.20253<br />call_time: 63.92554<br />issue_category: other","wait_time: 257.25316<br />call_time: 63.34418<br />issue_category: other","wait_time: 254.30380<br />call_time: 62.76282<br />issue_category: other","wait_time: 251.35443<br />call_time: 62.18147<br />issue_category: other","wait_time: 248.40506<br />call_time: 61.60011<br />issue_category: other","wait_time: 245.45570<br />call_time: 61.01875<br />issue_category: other","wait_time: 242.50633<br />call_time: 60.43739<br />issue_category: other","wait_time: 239.55696<br />call_time: 59.85604<br />issue_category: other","wait_time: 236.60759<br />call_time: 59.27468<br />issue_category: other","wait_time: 233.65823<br />call_time: 58.69332<br />issue_category: other","wait_time: 230.70886<br />call_time: 58.11196<br />issue_category: other","wait_time: 227.75949<br />call_time: 57.53061<br />issue_category: other","wait_time: 224.81013<br />call_time: 56.94925<br />issue_category: other","wait_time: 221.86076<br />call_time: 56.36789<br />issue_category: other","wait_time: 218.91139<br />call_time: 55.78653<br />issue_category: other","wait_time: 215.96203<br />call_time: 55.20518<br />issue_category: other","wait_time: 213.01266<br />call_time: 54.62382<br />issue_category: other","wait_time: 210.06329<br />call_time: 54.04246<br />issue_category: other","wait_time: 207.11392<br />call_time: 53.46111<br />issue_category: other","wait_time: 204.16456<br />call_time: 52.87975<br />issue_category: other","wait_time: 201.21519<br />call_time: 52.29839<br />issue_category: other","wait_time: 198.26582<br />call_time: 51.71703<br />issue_category: other","wait_time: 195.31646<br />call_time: 51.13568<br />issue_category: other","wait_time: 192.36709<br />call_time: 50.55432<br />issue_category: other","wait_time: 189.41772<br />call_time: 49.97296<br />issue_category: other","wait_time: 186.46835<br />call_time: 49.39160<br />issue_category: other","wait_time: 183.51899<br />call_time: 48.81025<br />issue_category: other","wait_time: 180.56962<br />call_time: 48.22889<br />issue_category: other","wait_time: 177.62025<br />call_time: 47.64753<br />issue_category: other","wait_time: 174.67089<br />call_time: 47.06618<br />issue_category: other","wait_time: 171.72152<br />call_time: 46.48482<br />issue_category: other","wait_time: 168.77215<br />call_time: 45.90346<br />issue_category: other","wait_time: 165.82278<br />call_time: 45.32210<br />issue_category: other","wait_time: 162.87342<br />call_time: 44.74075<br />issue_category: other","wait_time: 159.92405<br />call_time: 44.15939<br />issue_category: other","wait_time: 156.97468<br />call_time: 43.57803<br />issue_category: other","wait_time: 154.02532<br />call_time: 42.99667<br />issue_category: other","wait_time: 151.07595<br />call_time: 42.41532<br />issue_category: other","wait_time: 148.12658<br />call_time: 41.83396<br />issue_category: other","wait_time: 145.17722<br />call_time: 41.25260<br />issue_category: other","wait_time: 142.22785<br />call_time: 40.67124<br />issue_category: other","wait_time: 139.27848<br />call_time: 40.08989<br />issue_category: other","wait_time: 136.32911<br />call_time: 39.50853<br />issue_category: other","wait_time: 133.37975<br />call_time: 38.92717<br />issue_category: other","wait_time: 130.43038<br />call_time: 38.34582<br />issue_category: other","wait_time: 127.48101<br />call_time: 37.76446<br />issue_category: other","wait_time: 124.53165<br />call_time: 37.18310<br />issue_category: other","wait_time: 121.58228<br />call_time: 36.60174<br />issue_category: other","wait_time: 118.63291<br />call_time: 36.02039<br />issue_category: other","wait_time: 115.68354<br />call_time: 35.43903<br />issue_category: other","wait_time: 112.73418<br />call_time: 34.85767<br />issue_category: other","wait_time: 109.78481<br />call_time: 34.27631<br />issue_category: other","wait_time: 106.83544<br />call_time: 33.69496<br />issue_category: other","wait_time: 103.88608<br />call_time: 33.11360<br />issue_category: other","wait_time: 100.93671<br />call_time: 32.53224<br />issue_category: other","wait_time:  97.98734<br />call_time: 31.95089<br />issue_category: other","wait_time:  95.03797<br />call_time: 31.36953<br />issue_category: other","wait_time:  92.08861<br />call_time: 30.78817<br />issue_category: other","wait_time:  89.13924<br />call_time: 30.20681<br />issue_category: other","wait_time:  86.18987<br />call_time: 29.62546<br />issue_category: other","wait_time:  83.24051<br />call_time: 29.04410<br />issue_category: other","wait_time:  80.29114<br />call_time: 28.46274<br />issue_category: other","wait_time:  77.34177<br />call_time: 27.88138<br />issue_category: other","wait_time:  74.39241<br />call_time: 27.30003<br />issue_category: other","wait_time:  71.44304<br />call_time: 26.71867<br />issue_category: other","wait_time:  68.49367<br />call_time: 26.13731<br />issue_category: other","wait_time:  65.54430<br />call_time: 25.55595<br />issue_category: other","wait_time:  62.59494<br />call_time: 24.97460<br />issue_category: other","wait_time:  59.64557<br />call_time: 24.39324<br />issue_category: other","wait_time:  56.69620<br />call_time: 23.81188<br />issue_category: other","wait_time:  53.74684<br />call_time: 23.23053<br />issue_category: other","wait_time:  50.79747<br />call_time: 22.64917<br />issue_category: other","wait_time:  47.84810<br />call_time: 22.06781<br />issue_category: other","wait_time:  44.89873<br />call_time: 21.48645<br />issue_category: other","wait_time:  41.94937<br />call_time: 20.90510<br />issue_category: other","wait_time:  39.00000<br />call_time: 20.32374<br />issue_category: other","wait_time:  39.00000<br />call_time: 20.32374<br />issue_category: other"],"type":"scatter","mode":"lines","line":{"width":3.77952755905512,"color":"transparent","dash":"solid"},"fill":"toself","fillcolor":"rgba(153,153,153,0.4)","hoveron":"points","hoverinfo":"x+y","name":"other","legendgroup":"other","showlegend":false,"xaxis":"x","yaxis":"y","frame":null}],"layout":{"margin":{"t":43.7625570776256,"r":7.30593607305936,"b":40.1826484018265,"l":43.1050228310502},"plot_bgcolor":"rgba(255,255,255,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"title":{"text":"Wait Time by Call Time","font":{"color":"rgba(0,0,0,1)","family":"","size":17.5342465753425},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[8.45,328.55],"tickmode":"array","ticktext":["100","200","300"],"tickvals":[100,200,300],"categoryorder":"array","categoryarray":["100","200","300"],"nticks":null,"ticks":"outside","tickcolor":"rgba(179,179,179,1)","ticklen":3.65296803652968,"tickwidth":0.33208800332088,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(222,222,222,1)","gridwidth":0.33208800332088,"zeroline":false,"anchor":"y","title":{"text":"Wait Time","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-8.61773278770039,182.6960825137],"tickmode":"array","ticktext":["0","50","100","150"],"tickvals":[0,50,100,150],"categoryorder":"array","categoryarray":["0","50","100","150"],"nticks":null,"ticks":"outside","tickcolor":"rgba(179,179,179,1)","ticklen":3.65296803652968,"tickwidth":0.33208800332088,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(222,222,222,1)","gridwidth":0.33208800332088,"zeroline":false,"anchor":"x","title":{"text":"Call Time","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":"transparent","line":{"color":"rgba(179,179,179,1)","width":0.66417600664176,"linetype":"solid"},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":true,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.88976377952756,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.689497716895},"title":{"text":"Issue Category","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187}}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"d8f12ce18afc":{"x":{},"y":{},"colour":{},"type":"scatter"},"d8f1b6bbd69":{"x":{},"y":{},"colour":{}}},"cur_data":"d8f12ce18afc","visdat":{"d8f12ce18afc":["function (y) ","x"],"d8f1b6bbd69":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

<p class="caption">(\#fig:plotly)Interactive graph using plotly</p>
</div>

::: {.info data-latex=""}
Hover over the data points above and click on the legend items.
:::

#### Waffle Plots

In Chapter\ \@ref(ggplot), we mentioned that pie charts are such a poor way to visualise proportions that we refused to even show you how to make one. Waffle plots are a delicious alternative. 

::: {.warning data-latex=""}
Use <code class='package'>waffle</code> by [hrbrmstr on GitHub](https://github.com/hrbrmstr/waffle/) using the `install_github()` function below, rather than the one on CRAN you get from using `install.packages()`.


```r
devtools::install_github("hrbrmstr/waffle")
```

:::

By default, `geom_waffle()` represents each observation with a tile and splits these across 10 rows. You can play about with the `n_rows` argument to determine what works best for your data.


```r
survey_data |> 
  count(issue_category) |>
  ggplot(aes(fill = issue_category, values = n)) +
  geom_waffle(
    n_rows = 23, # try setting this to 10 (the default)
    size = 0.33, # line size
    make_proportional = FALSE, # use raw values
    colour = "white", # line colour
    flip = FALSE, # bottom-top or left-right
    radius = grid::unit(0.1, "npc") # set to 0.5 for circles
  ) +
  theme_enhance_waffle() + # gets rid of axes
  scale_fill_colorblind(name = "Issue Category")
```

<div class="figure" style="text-align: center">
<img src="10-custom_files/figure-html/unnamed-chunk-9-1.png" alt="Waffle plot." width="100%" />
<p class="caption">(\#fig:unnamed-chunk-9)Waffle plot.</p>
</div>

The waffle plot can also be used to display the counts as proportions To achieve these, set `n_rows = 10` and `make_proportional = TRUE`. Now, rather than each tile representing one observation, each tile represents 1% of the data. 


```r
survey_data |> 
  count(issue_category) |>
  ggplot(aes(fill = issue_category, values = n)) +
  geom_waffle(
    n_rows = 10, 
    size = 0.33, 
    make_proportional = TRUE, # compute proportions
    colour = "white", 
    flip = FALSE, 
    radius = grid::unit(0.1, "npc") 
  ) +
  theme_enhance_waffle() + 
  scale_fill_colorblind(name = "Issue Category")
```

<div class="figure" style="text-align: center">
<img src="10-custom_files/figure-html/unnamed-chunk-10-1.png" alt="Proportional waffle plot." width="100%" />
<p class="caption">(\#fig:unnamed-chunk-10)Proportional waffle plot.</p>
</div>

#### Treemap

Treemap plots are another way to visualise proportions. Like the waffle plots, you need to count the data by category first. You can use any [brewer palette](https://www.datanovia.com/en/blog/the-a-z-of-rcolorbrewer-palette/) for the fill. 


```r
survey_data |> 
  count(issue_category) |>
  treemap(
    index = "issue_category", # column with number of rectangles
    vSize = "n", # column with size of rectangle
    title = "",
    palette = "BuPu",
    inflate.labels = TRUE # expand labels to size of rectangle
  )
```

<div class="figure" style="text-align: center">
<img src="10-custom_files/figure-html/unnamed-chunk-11-1.png" alt="Treemap plot." width="100%" />
<p class="caption">(\#fig:unnamed-chunk-11)Treemap plot.</p>
</div>

You can also represent multiple categories with treemaps


```r
survey_data |> 
  count(issue_category, employee_id) |>
  arrange(employee_id) |>
  treemap(
    # use c() to specify two variables
    index = c("employee_id", "issue_category"), 
    vSize = "n", 
    title = "",
    palette = "Dark2",
    # set different label sizes for each type of label
    fontsize.labels = c(30, 10), 
    # set different alignments for two label types
    align.labels = list(c("left", "top"), c("center", "center")) 
  )
```

<div class="figure" style="text-align: center">
<img src="10-custom_files/figure-html/unnamed-chunk-12-1.png" alt="Treemap with two variables" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-12)Treemap with two variables</p>
</div>


#### Bump Plots

Bump plots are very useful for visualising how rankings change over time. So first, we need to get some ranking data. Let's start with a more typical raw data table, containing an identifying column of `person` and three columns for their scores each week


```r
# make a small dataset of scores for 3 people over 3 weeks
score_data <- tribble(
  ~person, ~week_1, ~week_2, ~week_3,
  "Abeni",      80,     75,       90,
  "Beth",       75,     85,       75,
  "Carmen",     60,     70,       80
)
```

Now we make the table long, group by week, and use the `rank()` function to find the rank of each person's score each week. Use `n() - rank(score) + 1` to reverse the ranks so that the highest score gets rank 1. We also need to make the `week` variable a number.


```r
# calculate ranks
rank_data <- score_data |>
  pivot_longer(cols = -person,
               names_to = "week",
               values_to = "score") |>
  group_by(week) |>
  mutate(rank = n() - rank(score) + 1) |>
  ungroup() |>
  arrange(week, rank) |>
  mutate(week = str_replace(week, "week_", "") |> as.integer())

rank_data
```

<div class="kable-table">

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> person </th>
   <th style="text-align:right;"> week </th>
   <th style="text-align:right;"> score </th>
   <th style="text-align:right;"> rank </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Abeni </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 80 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Beth </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Carmen </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 60 </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Beth </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 85 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Abeni </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Carmen </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 70 </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Abeni </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 90 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Carmen </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 80 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Beth </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
</tbody>
</table>

</div>

A typical mapping for a bump plot puts the time variable in the x-axis, the rank variable on the y-axis, and sets colour to the identifying variable.


```r
ggplot(data = rank_data, 
       mapping = aes(x = week, 
                     y = rank, 
                     colour = person)) +
  ggbump::geom_bump()
```

<div class="figure" style="text-align: center">
<img src="10-custom_files/figure-html/basic-bump-1.png" alt="Basic bump plot" width="100%" />
<p class="caption">(\#fig:basic-bump)Basic bump plot</p>
</div>

We can make this more attractive by customising the axes and adding text labels. Try running each line of this code to see how it builds up.

* Add `label = person` to the mapping so we can add in text labels.
* Increase the size of the lines with the `size` argument to `geom_bump()`
* We don't need labels for weeks 1.5 and 2.5, so change the x-axis `breaks`
* The `expand` argument for the two scale_ functions expands the plot area so we can fit text labels to the right.
* It makes more sense to have first place at the top, so reverse the order of the y-axis with `scale_y_reverse()` and fix the breaks and expansion.
* Add text labels with `geom_text()`, but just for week 3, so set `data =  filter(rank_data, week == 3)` for this geom. 
* Set `x = 3.05` to move the text labels just to the right of week 3, and set `hjust = 0` to right-justify the text labels (the default is `hjust = 0.5`, which would center them on 3.05).
* Remove the legend and grid lines. Increase the x-axis text size.


```r
ggplot(data = rank_data, 
       mapping = aes(x = week, 
                     y = rank, 
                     colour = person,
                     label = person)) +
  ggbump::geom_bump(size = 10) +
  scale_x_continuous(name = "",
                     breaks = 1:3, 
                     labels = c("Week 1", "Week 2", "Week 3"),
                     expand = expansion(c(.05, .2))) +
  scale_y_reverse(name = "Ranking",
                  breaks = 1:3, 
                  expand = expansion(.2)) +
  geom_text(data = filter(rank_data, week == 3),
            color = "black", x = 3.05, hjust = 0) +
  theme(legend.position = "none",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(size = 12))
```

<div class="figure" style="text-align: center">
<img src="10-custom_files/figure-html/bump-example-1.png" alt="Bump plot with added features." width="100%" />
<p class="caption">(\#fig:bump-example)Bump plot with added features.</p>
</div>


#### Word Clouds

Word clouds are a common way to summarise text data. First, download <a href="https://psyteachr.github.io/reprores-v3/data/amazon_alexa.csv" download>amazon_alexa.csv</a> into your data folder and then load it into an object. This dataset contains  text reviews as well as the 1-5 rating from customers who bought an Alexa device on Amazon.


```r
# https://www.kaggle.com/sid321axn/amazon-alexa-reviews
# extracted from Amazon by Manu Siddhartha & Anurag Bhatt
alexa <- rio::import("data/amazon_alexa.csv")
```

We can use this data to look at how the words used differ depending on the rating given. To make the text data easy to work with, the function `tidytext::unnest_tokens()` splits the words in the `input` column into individual words in a new `output` column. `unnnest_tokens()` is particularly helpful because it also does things like removes punctuation and transforms all words to lower case to make it easier to work with. Compare `words` and `alexa` to see how they map on to each other.


```r
words <- alexa |>
  unnest_tokens(output = "word", input = "verified_reviews")
```

We can then add another line of code using a pipe that counts how many instances of each word there is by rating to give us the most popular words.


```r
words <- alexa |>
  unnest_tokens(output = "word", input = "verified_reviews") |>
  count(word, rating, sort = TRUE) 
```

<div class="kable-table">

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> word </th>
   <th style="text-align:right;"> rating </th>
   <th style="text-align:right;"> n </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> i </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 1859 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> the </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 1839 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> to </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 1633 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> it </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 1571 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> and </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 1477 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> my </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 980 </td>
  </tr>
</tbody>
</table>

</div>

The problem is that the most common words are all function words rather than content words, which makes sense because these words have the highest word frequency in natural language.

Helpfully, `tidytext` contains a list of common "stop words", i.e., words that you want to ignore, that are stored in an object named `stop_words`.  It is also very useful to define a list of custom stop words based upon the unique properties of your data (it can sometimes take a few attempts to identify what's appropriate for your dataset). This dataset contains a lot of numbers that aren't informative, and it also contains "https" from website links, so we'll get rid of both with a custom stop list.

Once you have defined your stop words, you can then use `anti_join()`  to remove any `word` that is present in the stop word list.

To get the top 25 words, we then group by rating and use `dplyr::slice_max()`, ordered by the column `n`. 


```r
custom_stop <- tibble(word = c(0:9, "https", 34))

words <- alexa |>
  unnest_tokens(output = "word", input = "verified_reviews") |>
  count(word, rating) |>
  anti_join(stop_words, by = "word") |>
  anti_join(custom_stop, by = "word") |>
  group_by(rating) |>
  slice_max(order_by = n, n = 25, with_ties = FALSE) |>
  ungroup()
```

First, let's make a word cloud for customers who gave a 1-star rating:

* Filter retains only the data for 1-star ratings. 
* `label` comes from the `word` column and is the data to plot (i.e., the words).
* `colour` makes the words red (you could also set this to `word` to give each word a different colour or `n` to vary colour continuously by frequency).
* `size` makes the size of the word proportional to `n`, the number of times the word appeared.
* <code><span><span class='fu'>ggwordcloud</span><span class='fu'>::</span><span class='fu'><a target='_blank' href='https://lepennec.github.io/ggwordcloud/reference/geom_text_wordcloud.html'>geom_text_wordcloud_area</a></span><span class='op'>(</span><span class='op'>)</span></span></code> is the word cloud geom. 
* <code><span><span class='fu'>ggwordcloud</span><span class='fu'>::</span><span class='fu'>scale_size_area</span><span class='op'>(</span><span class='op'>)</span></span></code> controls how big the word cloud is (this usually takes some trial-and-error).  


```r
rating1 <- filter(words, rating == 1) |>
  ggplot(aes(label = word, colour = "red", size = n)) +
  geom_text_wordcloud_area() +
  scale_size_area(max_size = 10) +
  ggtitle("Rating = 1") +
  theme_minimal(base_size = 14)

rating1
```

<img src="10-custom_files/figure-html/unnamed-chunk-20-1.png" width="100%" style="display: block; margin: auto;" />

We can now do the same but for 5-star ratings and paste the plots together with `patchwork` (word clouds don't play well with facets). 


```r
rating5 <- filter(words, rating == 5) |>
  ggplot(aes(label = word, size = n)) +
  geom_text_wordcloud_area(colour = "darkolivegreen3") +
  scale_size_area(max_size = 12) +
  ggtitle("Rating = 5") +
  theme_minimal(base_size = 14)

rating1 + rating5
```

<div class="figure" style="text-align: center">
<img src="10-custom_files/figure-html/unnamed-chunk-21-1.png" alt="Word cloud." width="100%" />
<p class="caption">(\#fig:unnamed-chunk-21)Word cloud.</p>
</div>

::: {.warning data-latex=""}
It's worth highlighting that whilst word clouds are very common, they're really the equivalent of pie charts for text data because we're not very good at making accurate comparisons based on size. You might be able to see what's the most popular word, but can you accurately determine the 2nd, 3rd, 4th or 5th most popular word based on the clouds alone? There's also the issue that just because it's text data doesn't make it a qualitative analysis and just because something is said a lot doesn't mean it's useful or important. But, this argument is outwith the scope of this book, even if it is a recurring part of Emily's life thanks to her qualitative wife. 
:::


#### Maps

Working with maps can be tricky. The <code class='package'>sf</code> package provides functions that work with <code class='package'>ggplot2</code>, such as `geom_sf()`. The <code class='package'>rnaturalearth</code> package (and associated data packages that you may be prompted to download) provide high-quality mapping coordinates.

* `ne_countries()` returns world country polygons (i.e., a world map). We specify the object should be returned as a "simple feature" class `sf` so that it will work with `geom_sf()`. If you would like a deep dive on simple feature objects, check out a [vignette](https://r-spatial.github.io/sf/articles/sf1.html) from the <code class='package'>sf</code> package.
* It's worth checking out what the object `ne_countries()` returns to see just how much information is available.
* Try changing the values and colours below to get a sense of how the code works.



```r
# get the world map coordinates
world_sf <- ne_countries(returnclass = "sf", scale = "medium")

# plot them on a light blue background
ggplot() + 
  geom_sf(data = world_sf, size = 0.3) +
  theme(panel.background = element_rect(fill = "lightskyblue2"))
```

<img src="10-custom_files/figure-html/map-world-1.png" width="100%" style="display: block; margin: auto;" />

You can combine multiple countries using `bind_rows()` and visualise them with different colours for each country.


```r
# get and bind country data
uk_sf <- ne_states(country = "united kingdom", returnclass = "sf")
ireland_sf <- ne_states(country = "ireland", returnclass = "sf")
islands <- bind_rows(uk_sf, ireland_sf) |>
  filter(!is.na(geonunit))

# set colours
country_colours <- c("Scotland" = "#0962BA",
                     "Wales" = "#00AC48",
                     "England" = "#FF0000",
                     "Northern Ireland" = "#FFCD2C",
                     "Ireland" = "#F77613")

ggplot() + 
  geom_sf(data = islands,
          mapping = aes(fill = geonunit),
          colour = NA,
          alpha = 0.75) +
  coord_sf(crs = sf::st_crs(4326),
           xlim = c(-10.7, 2.1), 
           ylim = c(49.7, 61)) +
  scale_fill_manual(name = "Country", 
                    values = country_colours)
```

<div class="figure" style="text-align: center">
<img src="10-custom_files/figure-html/map-islands-1.png" alt="Map coloured by country." width="100%" />
<p class="caption">(\#fig:map-islands)Map coloured by country.</p>
</div>


You can join <a href="https://psyteachr.github.io/reprores-v3/data/scottish_population.csv" download>Scottish population data</a> to the map table to visualise data on the map using colours or labels.


```r
# load map data
scotland_sf <- ne_states(geounit = "Scotland", 
                         returnclass = "sf")

# load population data from
# https://www.indexmundi.com/facts/united-kingdom/quick-facts/scotland/population
scotpop <- read_csv("data/scottish_population.csv", 
                    show_col_types = FALSE)

# join data and fix typo in the map
scotmap_pop <- scotland_sf |>
  mutate(name = ifelse(name == "North Ayshire", 
                       yes = "North Ayrshire", 
                       no = name)) |>
  left_join(scotpop, by = "name") |>
  select(name, population, geometry)
```

::: {.warning data-latex=""}
There is a typo in the data from <code class='package'>rnaturalearth</code>, so you need to change "North Ayshire" to "North Ayrshire" before you join the population data.
:::

* Setting the fill to population in `geom_sf()` gives each region a colour based on its population. 
* The colours are customised with `scale_fill_viridis_c()`. The breaks of the fill scale are set to increments of 100K (1e5 in scientific notation) and the scale is set to span 0 to 600K. 
* `paste0()` creates the labels by taking the numbers 0 through 6 and adding "00 k" to them.
* Finally, the position of the legend is moved into the sea using `legend.position()`.


```r
# plot
ggplot() + 
  geom_sf(data = scotmap_pop,
          mapping = aes(fill = population),
          color = "white", 
          size = .1) +
  coord_sf(xlim = c(-8, 0), ylim = c(54, 61)) +
  scale_fill_viridis_c(name = "Population",
                       breaks = seq(from = 0, to = 6e5, by = 1e5), 
                       limits = c(0, 6e5),
                       labels = paste0(0:6, "00 K")) +
  theme(legend.position = c(0.16, 0.84))
```

<div class="figure" style="text-align: center">
<img src="10-custom_files/figure-html/map-scotland-1.png" alt="Map coloured by population." width="100%" />
<p class="caption">(\#fig:map-scotland)Map coloured by population.</p>
</div>

#### Animated Plots

Animated plots are a great way to add a wow factor to your reports, but they can be complex to make, distracting, and not very accessible, so use them sparingly and only for data visualisation where the animation really adds something. The package <code class='package'><a href='https://gganimate.com/' target='_blank'>gganimate</a></code> has many functions for animating ggplots.

Here, we'll load some population data from the United Nations. <a href="data/WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx" download>Download the file</a> into your data folder and open it in Excel first to see what it looks like. The code below gets the data from the first tab, filters it to just the 6 world regions, makes the data long, and makes sure the `year` column is numeric and the `pop` column shows population in whole numbers (the original data is in 1000s).


```r
# load and process data
worldpop <- readxl::read_excel("data/WPP2019_POP_F01_1_TOTAL_POPULATION_BOTH_SEXES.xlsx", skip = 16) |>
  filter(Type == "Region") |>
  select(region = 3, `1950`:`1992`) |>
  pivot_longer(cols = -region, 
               names_to = "year",
               values_to = "pop") |>
  mutate(year = as.integer(year),
         pop = round(1000 * as.numeric(pop)))
```

Let's make an animated plot showing how the population in each region changes with year. First, make a static plot. Filter the data to the most recent year so you can see what a single frame of the animation will look like.


```r
worldpop |>
  filter(year == 1992) |>
  ggplot(aes(x = region, y = pop, fill = region)) +
  geom_col(show.legend = FALSE) +
  scale_fill_viridis_d() +
  scale_x_discrete(name = "", 
                   guide = guide_axis(n.dodge=2))+
  scale_y_continuous(name = "Population",
                     breaks = seq(0, 3e9, 1e9),
                     labels = paste0(0:3, "B")) +
  ggtitle('Year: 1992')
```

<img src="10-custom_files/figure-html/unnamed-chunk-24-1.png" width="100%" style="display: block; margin: auto;" />

To convert this to an animated plot that shows the data from multiple years:

* Remove the filter and add `transition_time(year)`. 
* Use the `{}` syntax to include the `frame_time` in the title. 
* Use `anim_save()` to save the animation to a GIF file and set this code chunk to `eval = FALSE` because creating an animation takes a long time and you don't want to have to run it every time you knit your report.


```r
anim <- worldpop |>
  ggplot(aes(x = region, y = pop, fill = region)) +
  geom_col(show.legend = FALSE) +
  scale_fill_viridis_d() +
  scale_x_discrete(name = "",
                   guide = guide_axis(n.dodge=2))+
  scale_y_continuous(name = "Population",
                     breaks = seq(0, 3e9, 1e9),
                     labels = paste0(0:3, "B")) +
  ggtitle('Year: {frame_time}') +
  transition_time(year)
  
dir.create("images", FALSE) # creates an images directory if needed

anim_save(filename = "images/gganim-demo.gif",
          animation = anim,
          width = 8, height = 5, units = "in", res = 150)
```

You can show your animated gif in an html report (animations don't work in Word or a PDF) using `include_graphics()`, or include the GIF in a dynamic document like PowerPoint.


```r
knitr::include_graphics("images/gganim-demo.gif")
```

<div class="figure" style="text-align: center">
<img src="images/gganim-demo.gif" alt="Animated gif." width="100%" />
<p class="caption">(\#fig:anim-demo)Animated gif.</p>
</div>


::: {.warning data-latex=""}
There are actually not many plots that are really improved by animating them. The plot below gives the same information at a single glance.

<img src="10-custom_files/figure-html/anim-alternative-1.png" width="100%" style="display: block; margin: auto;" />

:::

### Resources  {#resources-custom}

There are so many more options for data visualisation in R than we have time to cover here. The following resources will get you started on your journey to informative, intuitive visualisations.

* [The R Graph Gallery](http://www.r-graph-gallery.com/) (this is really useful)
* [Look at Data](https://socviz.co/lookatdata.html) from [Data Vizualization for Social Science](http://socviz.co/)
* [Graphs](http://www.cookbook-r.com/Graphs) in *Cookbook for R*
* [Top 50 ggplot2 Visualizations](http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html)
* [R Graphics Cookbook](http://www.cookbook-r.com/Graphs/) by Winston Chang
* [ggplot extensions](https://exts.ggplot2.tidyverse.org/)
* [plotly](https://plot.ly/ggplot2/) for creating interactive graphs
* [Drawing Beautiful Maps Programmatically](https://r-spatial.org/r/2018/10/25/ggplot2-sf.html)
* [gganimate](https://gganimate.com/)


## Reports {#custom-reports}

### Set-up {#setup-custom-reports}

Close your visualisation Markdown and open and save an new R Markdown document named `reports.Rmd`, delete the welcome text and load the required packages for this section.


```r
library(tidyverse)     # data wrangling functions
library(bookdown)      # for chaptered reports
library(flexdashboard) # for dashboards
library(DT)            # for interactive tables
```

You'll need to make a folder called "data" and download data files into it: 
<a href="https://psyteachr.github.io/reprores-v3/data/amazon_alexa.csv" download>amazon_alexa.csv</a> and <a href="https://psyteachr.github.io/reprores-v3/data/scottish_population.csv" download>scottish_population.csv</a>.

### Linked documents

If you need to create longer reports with links between sections, you can edit the YAML to use a bookdown format. `bookdown::html_document2` is a useful one that adds figure and table numbers automatically to any figures or tables with a caption and allows you to link to these by reference.

To create links to tables and figures, you need to name the code chunk that created your figures or tables, and then call those names in your inline coding:

<div class='verbatim'><pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;{r my-table}</code></pre>

```r
# table code here
```

<pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;</code></pre></div>

<div class='verbatim'><pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;{r my-figure}</code></pre>

```r
# figure code here
```

<pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;</code></pre></div>

```
See Table\ \@ref(tab:my-table) or Figure\ \@ref(fig:my-figure).
```

::: {.warning data-latex=""}
The code chunk names can only contain letters, numbers and dashes. If they contain other characters like spaces or underscores, the referencing will not work.
:::

You can also link to different sections of your report by naming your headings with `{#}`:

```
# My first heading {#heading-1}

## My second heading {#heading-2}

See Section\ \@ref(heading-1) and Section\ \@ref(heading-2)

```
The code below shows how to link text to figures or tables in a full report using the built-in `diamonds` dataset - use your `reports.Rmd` to create this document now. You can see the [HTML output here](demos/html_document2.html).


<div class='webex-solution'><button>Linked document code</button>



````md
---
title: "Linked Document Demo"
output: 
  bookdown::html_document2:
    number_sections: true
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE,
                      message = FALSE,
                      warning = FALSE)
library(tidyverse)
library(kableExtra)
theme_set(theme_minimal())
```

Diamond price depends on many features, such as:

- cut (See Table\ \@ref(tab:by-cut))
- colour (See Table\ \@ref(tab:by-colour))
- clarity (See Figure\ \@ref(fig:by-clarity))
- carats (See Figure\ \@ref(fig:by-carat))
- See section\ \@ref(conclusion) for concluding remarks

## Tables

### Cut

```{r by-cut}
diamonds %>%
  group_by(cut) %>%
  summarise(avg = mean(price),
            .groups = "drop") %>%
  kable(digits = 0, 
        col.names = c("Cut", "Average Price"),
        caption = "Mean diamond price by cut.") %>%
  kable_material()
```

### Colour

```{r by-colour}
diamonds %>%
  group_by(color) %>%
  summarise(avg = mean(price),
            .groups = "drop") %>%
  kable(digits = 0, 
        col.names = c("Cut", "Average Price"),
        caption = "Mean diamond price by colour.") %>%
  kable_material()
```

## Plots

### Clarity

```{r by-clarity, fig.cap = "Diamond price by clarity"}
ggplot(diamonds, aes(x = clarity, y = price)) +
  geom_boxplot() 
```

### Carats

```{r by-carat, fig.cap = "Diamond price by carat"}
ggplot(diamonds, aes(x = carat, y = price)) +
  stat_smooth()
```

### Concluding remarks {#conclusion}

I am not rich enough to worry about any of this.
````


</div>


This format defaults to numbered sections, so set `number_sections: false` in the <a class='glossary' target='_blank' title='A structured format for information' href='https://psyteachr.github.io/glossary/y#yaml'>YAML</a> header if you don't want this. If you remove numbered sections, links like `\@ref(conclusion)` will show "??", so you need to use URL link syntax instead, like this:

```
See the [last section](#conclusion) for concluding remarks.
```


### Interactive tables

One way to make your reports more exciting is to use interactive tables. The `DT::datatable()` function displays a table with some extra interactive elements to allow readers to search and reorder the data, as well as controlling the number of rows shown at once. This can be especially helpful. This only works with HTML output types. The [DT website](https://rstudio.github.io/DT/){target="_blank"} has extensive tutorials, but we'll cover the basics here.


```r
library(DT)

scotpop <- read_csv("data/scottish_population.csv", 
                    show_col_types = FALSE)

datatable(data = scotpop)
```

```{=html}
<div id="htmlwidget-dce5cf135a3053180d85" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-dce5cf135a3053180d85">{"x":{"filter":"none","vertical":false,"data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32"],["Aberdeen","Aberdeenshire","Angus","Argyll and Bute","Edinburgh","Clackmannanshire","Dumfries and Galloway","Dundee","East Ayrshire","East Dunbartonshire","East Lothian","East Renfrewshire","Eilean Siar","Falkirk","Fife","Glasgow","Highland","Inverclyde","Midlothian","Moray","North Ayrshire","North Lanarkshire","Orkney","Perthshire and Kinross","Renfrewshire","Scottish Borders","Shetland Islands","South Ayrshire","South Lanarkshire","Stirling","West Dunbartonshire","West Lothian"],[217120,245780,110570,89200,486120,50630,148190,144290,120240,104580,97500,89540,26190,153280,365020,592820,221630,79770,81140,87720,135180,326360,20110,147780,170250,112870,22400,111440,311880,89850,90570,172080]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>name<\/th>\n      <th>population<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":2},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>
```


You can customise the display, such as changing column names, adding a caption, moving the location of the filter boxes, removing row names, applying [classes](https://datatables.net/manual/styling/classes){target="_blank"} to change table appearance, and applying [advanced options](https://datatables.net/reference/option/){target="_blank"}.


```r
# https://datatables.net/reference/option/
my_options <- list(
  pageLength = 5, # how many rows are displayed
  lengthChange = FALSE, # whether pageLength can change
  info = TRUE, # text with the total number of rows
  paging = TRUE, # if FALSE, the whole table displays
  ordering = FALSE, # whether you can reorder columns
  searching = FALSE # whether you can search the table
)

datatable(
  data = scotpop,
  colnames = c("County", "Population"),
  caption = "The population of Scottish counties.",
  filter = "none", # "none", "bottom" or "top"
  rownames = FALSE, # removes the number at the left
  class = "cell-border hover stripe", # default is "display"
  options = my_options
)
```

```{=html}
<div id="htmlwidget-dfe8593ac3f5ba0fcbb4" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-dfe8593ac3f5ba0fcbb4">{"x":{"filter":"none","vertical":false,"caption":"<caption>The population of Scottish counties.<\/caption>","data":[["Aberdeen","Aberdeenshire","Angus","Argyll and Bute","Edinburgh","Clackmannanshire","Dumfries and Galloway","Dundee","East Ayrshire","East Dunbartonshire","East Lothian","East Renfrewshire","Eilean Siar","Falkirk","Fife","Glasgow","Highland","Inverclyde","Midlothian","Moray","North Ayrshire","North Lanarkshire","Orkney","Perthshire and Kinross","Renfrewshire","Scottish Borders","Shetland Islands","South Ayrshire","South Lanarkshire","Stirling","West Dunbartonshire","West Lothian"],[217120,245780,110570,89200,486120,50630,148190,144290,120240,104580,97500,89540,26190,153280,365020,592820,221630,79770,81140,87720,135180,326360,20110,147780,170250,112870,22400,111440,311880,89850,90570,172080]],"container":"<table class=\"cell-border hover stripe\">\n  <thead>\n    <tr>\n      <th>County<\/th>\n      <th>Population<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":5,"lengthChange":false,"info":true,"paging":true,"ordering":false,"searching":false,"columnDefs":[{"className":"dt-right","targets":1}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>
```

::: {.try data-latex=""}
Create an interactive table like the one below from the `diamonds` dataset of diamonds where the `table` value is greater than 65 (the whole table is *much* too large to display with an interactive table). Show 20 items by default and remove the search box, but leave in the filter and other default options.


```{=html}
<div id="htmlwidget-99c2b8d42e8d4a8e1295" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-99c2b8d42e8d4a8e1295">{"x":{"filter":"none","vertical":false,"caption":"<caption>All diamonds with table &gt; 65.<\/caption>","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","100","101","102","103","104","105","106","107","108","109","110","111","112","113","114","115","116","117","118","119","120","121","122","123","124","125","126","127","128","129","130","131","132","133","134","135","136","137","138","139","140","141","142","143","144","145","146","147","148","149","150","151","152","153","154","155","156","157","158","159","160","161","162","163","164","165","166","167","168","169","170","171","172","173","174","175","176","177","178","179","180","181"],[0.86,0.84,0.7,0.76,0.57,0.74,0.91,0.98,0.75,0.72,0.9,0.75,0.99,0.98,1.06,0.85,0.73,1.2,0.91,1,0.95,0.9,0.9,0.99,0.9,1.01,0.98,0.96,1,1.01,1.01,1.17,1.18,0.9,1,1.01,0.9,1,0.94,0.97,0.31,0.91,1.05,1.45,1,0.51,1.07,0.9,0.91,1.18,1.07,1.45,1.13,1.17,0.3,1,1.01,0.93,1.01,1,1.65,1.14,1.5,1.16,1.42,1.24,2.01,1.44,1.57,1.5,1.51,1.52,1.53,1.76,1.55,1.51,1.52,1,1.51,1.5,1.51,2,2.1,1.91,2,1.32,2.29,1.98,1.51,2.01,2.01,2.29,2.01,2.48,2.01,0.23,2.1,0.23,0.3,0.45,0.36,0.5,0.5,0.23,0.46,0.3,0.4,0.43,0.46,0.5,0.54,0.5,0.7,0.5,0.5,0.49,0.56,0.5,0.51,0.89,0.5,0.52,0.64,0.52,0.67,0.68,0.62,0.67,0.7,0.53,0.5,0.56,0.57,0.75,0.71,0.71,0.7,0.75,0.73,0.96,0.7,0.5,0.75,0.77,0.74,0.7,0.7,0.7,0.7,0.77,0.69,0.7,0.9,0.6,0.71,0.7,0.69,0.77,0.81,0.71,0.76,0.73,0.62,0.7,0.79,0.71,0.7,1.05,0.71,0.6,0.82,0.76,0.97,0.88,0.5,0.5,0.89,0.72,0.71,0.78,0.71],["Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Good","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Good","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Good","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Good","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Good","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Very Good","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair","Fair"],["E","G","G","G","E","F","H","E","F","F","I","E","J","F","J","G","F","I","D","G","J","E","I","I","I","F","F","E","D","G","G","I","D","D","F","E","F","F","F","F","E","H","I","F","H","F","E","F","E","I","F","J","I","H","F","G","H","D","D","G","J","G","G","F","G","D","F","H","H","E","F","H","I","J","F","G","G","D","E","E","H","I","G","I","F","F","J","H","G","F","H","J","E","I","D","D","F","G","G","F","F","F","E","F","G","E","G","H","G","E","F","H","H","F","E","D","H","G","F","H","F","I","I","F","I","G","F","F","E","E","G","F","G","J","H","I","I","J","I","F","F","G","J","J","J","H","G","G","E","J","G","H","E","G","F","I","G","I","F","F","H","I","E","G","G","D","H","I","F","F","F","D","J","I","E","E","G","H","G","H","F"],["SI2","SI1","VVS1","VS1","VVS1","VS2","SI2","SI2","VS1","VS1","VS2","VS2","SI1","SI2","SI2","VS1","VS1","I1","SI2","SI2","SI1","SI2","VVS2","SI1","VS2","SI2","SI1","SI2","SI2","SI2","SI2","SI2","SI2","VS2","SI2","SI2","VS2","SI2","SI1","SI1","SI1","VVS1","VS1","I1","VS1","VVS2","SI2","VS2","VS2","VS2","SI1","SI2","VS2","SI2","VS1","VS1","VS1","VS2","VS2","VS1","SI1","VS1","SI2","VS1","VS2","SI1","I1","VS1","VS1","SI2","SI2","VS2","VS2","VS1","SI1","VS2","VS2","VVS1","SI1","SI1","VS1","VS1","SI2","VS1","SI2","VVS1","SI1","VS1","VS1","SI1","SI2","VS2","SI2","SI2","SI2","VVS1","SI2","VVS2","VVS1","SI1","VS1","I1","SI2","VVS1","SI1","VVS2","SI1","SI1","VS1","SI2","SI1","VS2","I1","SI2","SI1","VS2","VS2","VS1","VS2","I1","VS1","VVS2","VS2","SI1","VS2","SI1","SI1","SI1","SI2","VS1","VVS2","VS2","VS2","SI1","VS2","VS2","SI1","VS1","SI2","I1","SI2","VVS2","VS2","SI1","VS1","SI1","SI1","SI2","SI1","VS1","VS1","VS1","I1","VVS2","SI1","VS1","VS1","VVS2","SI2","SI2","SI1","VS1","VS1","SI1","SI1","VS2","VS1","I1","SI1","VVS2","SI2","SI2","SI2","VS2","VS2","VS2","SI2","VVS2","VS2","VS2","VS1"],[55.1,55.1,58.8,59,58.7,61.1,61.3,53.3,55.8,56.9,64.1,56,58,61.6,61,57.7,58.6,62.2,62.5,64.6,58,57.5,60.9,60.7,58.5,60.1,61.8,57.7,65.6,58.7,59.8,59.2,57,57.5,59.3,56.8,58.9,59,56.8,56.4,56.9,56.5,58.9,64.8,57.4,60.7,62.2,59.5,61.8,62,60.6,58.6,55.9,60,61.7,63.1,61.4,56.3,59.1,58.7,61.6,57.5,68.5,57.8,59.6,55.6,58.7,58.1,67.3,59.9,61.8,62.1,57.7,56.9,59.7,58.1,55.2,56.7,58.4,58.2,58,58.5,61.4,59.5,59.8,58,56.8,58.3,60.8,58.6,61.2,57,62.1,56.7,59.4,60.3,59.5,61.4,58.6,57.9,55.3,57.5,58,60.3,63.4,51,59.9,62.7,58,59.8,61.4,62.4,62.1,61.1,61.7,57.5,52.7,60.3,61,58.8,62.9,60.4,55.3,65.5,57.2,58,55.1,56,58.7,62.3,62.9,57,58.2,55,62.1,61.6,62,61.9,61.3,62.9,58.2,60.6,59.1,60.2,58.8,61,61.6,61.5,57.2,61.2,57.8,62,59.9,57.9,57,60.2,61.2,59.2,68.8,60.1,61.9,55.9,58.8,61.7,65.3,55.6,59.6,61.8,59.8,60.1,56.7,55.5,60.8,57.4,79,79,58.9,56.5,57,54.7,57.3],[2757,2782,2797,2800,2805,2805,2825,2855,2859,2879,2921,2940,2949,2958,2992,2998,3002,3011,3079,3142,3154,3187,3288,3337,3353,3597,3622,3674,3767,3816,3816,3833,3899,3931,3975,3991,3992,4036,4053,4063,579,4115,4281,4320,4368,4368,4496,4536,4550,4553,4554,4570,4695,4717,593,4892,5062,5078,5797,5853,5914,6381,6552,7094,7214,7291,7294,7338,8133,8190,8287,8674,8996,9314,10217,10553,10623,10752,11102,11128,11263,11322,11946,12244,12610,12648,12811,12923,12948,13387,13587,13701,14948,15030,15627,425,16506,369,790,794,810,827,851,472,911,945,960,984,1035,1114,1114,1122,1138,1156,1238,1249,1293,1327,1334,1334,1348,1401,1411,1427,1436,1633,1641,1642,1723,1778,1791,1814,1816,1827,1832,1840,1848,1869,1892,1917,1920,1939,1944,1956,1982,1995,1995,1999,2000,2005,2070,2100,2138,2167,2198,2234,2235,2292,2301,2327,2328,2330,2344,2352,2362,2368,2395,2396,2458,2484,2508,2518,2538,2550,2579,2579,2579,2608,2623,2691,2707]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>carat<\/th>\n      <th>cut<\/th>\n      <th>color<\/th>\n      <th>clarity<\/th>\n      <th>depth<\/th>\n      <th>price<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"pageLength":20,"searching":false,"columnDefs":[{"className":"dt-right","targets":[1,5,6]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false,"lengthMenu":[10,20,25,50,100]}},"evals":[],"jsHooks":[]}</script>
```


<div class='webex-solution'><button>Solution</button>

```r
my_options <- list(
  pageLength = 20, # how many rows are displayed
  searching = FALSE # whether you can search the table
)

diamonds |> 
  filter(table > 65) |>
  select(-table, -(x:z)) |>
  DT::datatable(
    caption = "All diamonds with table > 65.",
    options = my_options
  )
```


</div>
:::



### Other formats

You can create more than just reports with R Markdown. You can also create presentations, interactive dashboards, books, websites, and web applications.

#### Presentations

You can choose a presentation template when you create a new R Markdown document. We'll use ioslides for this example, but the other formats work similarly.

<div class="figure" style="text-align: center">
<img src="images/present/new-ioslides.png" alt="Ioslides RMarkdown template." width="100%" />
<p class="caption">(\#fig:img-ioslides-template)Ioslides RMarkdown template.</p>
</div>

The main differences between this and the Rmd files you've been working with until now are that the `output` type in the <a class='glossary' target='_blank' title='A structured format for information' href='https://psyteachr.github.io/glossary/y#yaml'>YAML</a> header is `ioslides_presentation` instead of `html_document` and this format requires a specific title structure. Each slide starts with a level-2 header.

The template provides you with examples of text, bullet point, code, and plot slides. You can knit this template to create an <a class='glossary' target='_blank' title='Hyper-Text Markup Language: A system for semantically tagging structure and information on web pages.' href='https://psyteachr.github.io/glossary/h#html'>HTML</a> document with your presentation. It often looks odd in the RStudio built-in browser, so click the button to open it in a web browser. You can use the space bar or arrow keys to advance slides.

The code below shows how to load some packages and display text, a table, and a plot. You can see the [HTML output here](demos/ioslides.html).


<div class='webex-solution'><button>Solution</button>



````md
---
title: "Presentation Demo"
author: "Lisa DeBruine"
output: ioslides_presentation
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE)
library(tidyverse)
library(kableExtra)
```

## Slide with Markdown

The following slides will present some data from the `diamonds` dataset from **ggplot2**.

Diamond price depends on many features, such as:

- cut
- colour
- clarity
- carats

## Slide with a Table

```{r}
diamonds %>%
  group_by(cut, color) %>%
  summarise(avg_price = mean(price),
            .groups = "drop") %>%
  pivot_wider(names_from = cut, values_from = avg_price) %>%
  kable(digits = 0, caption = "Mean diamond price by cut and colour.") %>%
  kable_material()
```

## Slide with a Plot

```{r pressure}
ggplot(diamonds, aes(x = cut, y = price, color = color)) +
  stat_summary(fun = mean, geom = "point") +
  stat_summary(aes(x = as.integer(cut)), 
               fun = mean, geom = "line") +
  scale_x_discrete(position = "top") +
  scale_color_viridis_d(guide = guide_legend(reverse = TRUE)) +
  theme_minimal() 
```

````


</div>


#### Dashboards

Dashboards are a way to display text, tables, and plots with dynamic formatting. After you install <code class='package'>flexdashboard</code>, you can choose a flexdashboard template when you create a new R Markdown document. 

<div class="figure" style="text-align: center">
<img src="images/present/flexdashboard-template.png" alt="Flexdashboard RMarkdown template." width="100%" />
<p class="caption">(\#fig:img-flx-template)Flexdashboard RMarkdown template.</p>
</div>

The code below shows how to load some packages, display two tables in a tabset, and display two plots in a column. You can see the [HTML output here](demos/flexdashboard.html).


<div class='webex-solution'><button>Solution</button>



````md
---
title: "Flexdashboard Demo"
output: 
  flexdashboard::flex_dashboard:
    social: [ "twitter", "facebook", "linkedin", "pinterest" ]
    source_code: embed
    orientation: columns
    vertical_layout: fill
---

```{r setup, include=FALSE}
library(flexdashboard)
library(tidyverse)
library(kableExtra)
library(DT) # for interactive tables
theme_set(theme_minimal())
```

Column {data-width=350, .tabset}
--------------------------------

### By Cut

This table uses `kableExtra` to render the table with a specific theme.

```{r}
diamonds %>%
  group_by(cut) %>%
  summarise(avg = mean(price),
            .groups = "drop") %>%
  kable(digits = 0, 
        col.names = c("Cut", "Average Price"),
        caption = "Mean diamond price by cut.") %>%
  kable_classic()
```

### By Colour

This table uses `DT::datatable()` to render the table with a searchable interface.

```{r}
diamonds %>%
  group_by(color) %>%
  summarise(avg = mean(price),
            .groups = "drop") %>%
  DT::datatable(colnames = c("Colour", "Average Price"), 
                caption = "Mean diamond price by colour",
                options = list(pageLength = 5),
                rownames = FALSE) %>%
  DT::formatRound(columns=2, digits=0)
```

Column {data-width=350}
-----------------------

### By Clarity

```{r by-clarity, fig.cap = "Diamond price by clarity"}
ggplot(diamonds, aes(x = clarity, y = price)) +
  geom_boxplot() 
```


### By Carats

```{r by-carat, fig.cap = "Diamond price by carat"}
ggplot(diamonds, aes(x = carat, y = price)) +
  stat_smooth()
```

````


</div>


Change the size of your web browser to see how the boxes, tables and figures change.

The best way to figure out how to format a dashboard is trial and error, but you can also look at some [sample layouts](https://pkgs.rstudio.com/flexdashboard/articles/layouts.html){target="_blank"}.

#### Books

You can create online books with <code class='package'>bookdown</code>. In fact, the book you're reading was created using bookdown. After you download the package, start a new project and choose "Book project using bookdown" from the list of project templates. 

<div class="figure" style="text-align: center">
<img src="images/present/bookdown.png" alt="Bookdown project template." width="100%" />
<p class="caption">(\#fig:img-bookdown-template)Bookdown project template.</p>
</div>

Each chapter is written in a separate .Rmd file and the general book settings can be changed in the `_bookdown.yml` and `_output.yml` files. 

#### Websites

You can create a simple website the same way you create any R Markdown document. Choose "Simple R Markdown Website" from the project templates to get started. See Appendix\ \@ref(webpages) for a step-by-step tutorial.

For more complex, blog-style websites, you can investigate [<code class='package'>blogdown</code>](https://bookdown.org/yihui/blogdown/). After you install this package, you will also be able to create template blogdown projects to get you started.

#### Shiny

To get truly interactive, you can take your R coding to the next level and learn Shiny. Shiny apps let your R code react to user input. You can do things like [make a word cloud](https://shiny.psy.gla.ac.uk/debruine/wordcloud/), [search a google spreadsheet](https://shiny.psy.gla.ac.uk/debruine/seen/), or [conduct a survey](https://shiny.psy.gla.ac.uk/debruine/question/).

This is well outside the scope of this class, but the skills you've learned here provide a good start. The free book [Building Web Apps with R Shiny](https://debruine.github.io/shinyintro/) by one of the authors of this book can get you started creating shiny apps.

### Resources {#resources-report}

* [RStudio Formats](https://rmarkdown.rstudio.com/formats.html)
* [R Markdown Cookbook](https://bookdown.org/yihui/rmarkdown-cookbook)
* [DT](https://rstudio.github.io/DT/)
* [Flexdashboard](https://pkgs.rstudio.com/flexdashboard/)
* [Bookdown](https://bookdown.org/yihui/bookdown/)
* [Blogdown](https://bookdown.org/yihui/blogdown/)
* [Shiny](https://shiny.rstudio.com/)
* [Building Web Apps with R Shiny](https://debruine.github.io/shinyintro/)
