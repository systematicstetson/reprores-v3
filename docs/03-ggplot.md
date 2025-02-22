# Data Visualisation {#ggplot}

<div class="right meme"><img src="images/memes/better_graphs.png" 
     alt = "xkcd comic titled 'General quality of charts and graphs in scientific papers'; y-axis: BAD on the bottom to GOOD on the top; x-axis: 1950s to 2010s; Line graph increases with time except for a dip between 1990 and 2010 labelled POWERPOINT/MSPAINT ERA" /></div>

## Learning Objectives {#ilo-ggplot}

### Basic {-}

1. Understand what types of graphs are best for [different types of data](#vartypes) [(video)](https://youtu.be/tOFQFPRgZ3M){class="video"}
2. Create common types of graphs with ggplot2 [(video)](https://youtu.be/kKlQupjD__g){class="video"}
3. Set custom [size](#custom-size),
              [labels](#custom-labels), 
              [colours](#custom-colours), and
              [themes](#themes) [(video)](https://youtu.be/6pHuCbOh86s){class="video"}
4. [Combine plots](#combo_plots) on the same plot, as facets, or as a grid using patchwork [(video)](https://youtu.be/AnqlfuU-VZk){class="video"}
5. [Save plots](#ggsave) as an image file [(video)](https://youtu.be/f1Y53mjEli0){class="video"}
    
### Intermediate {-}

6. Add lines to graphs
7. Deal with [overlapping data](#overlap)
8. Create less common types of graphs
9. Adjust axes (e.g., flip coordinates, set axis limits)


## Setup {#setup-ggplot}

1. Open your `reprores-class-notes` project 
1. Create a new R Markdown file called `03-ggplot.Rmd`
1. Update the YAML header 
1. Replace the setup chunk with the one below: 

<div class='verbatim'><pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;{r setup, include = FALSE}</code></pre>

```r
knitr::opts_chunk$set(echo = TRUE)

# packages needed for this chapter
library(tidyverse)   # loads ggplot2 for plots
library(patchwork)   # multi-part plots
library(plotly)      # interactive plots
library(reprores)    # class-specific datasets

set.seed(30250) # makes sure random numbers are reproducible
```

<pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;</code></pre></div>

Download the [ggplot2 cheat sheet](https://raw.githubusercontent.com/rstudio/cheatsheets/main/data-visualization.pdf).

## Common Variable Combinations {#vartypes}

<a class='glossary' target='_blank' title='Data that can take on any values between other existing values.' href='https://psyteachr.github.io/glossary/c#continuous'>Continuous</a> variables are properties you can measure, like height. <a class='glossary' target='_blank' title='Data that can only take certain values, such as integers.' href='https://psyteachr.github.io/glossary/d#discrete'>Discrete</a> variables are things you can count, like the number of pets you have. Categorical variables can be <a class='glossary' target='_blank' title='Categorical variables that don&#39;t have an inherent order, such as types of animal.' href='https://psyteachr.github.io/glossary/n#nominal'>nominal</a>, where the categories don't really have an order, like cats, dogs and ferrets (even though ferrets are obviously best). They can also be <a class='glossary' target='_blank' title='Discrete variables that have an inherent order, such as level of education or dislike/like.' href='https://psyteachr.github.io/glossary/o#ordinal'>ordinal</a>, where there is a clear order, but the distance between the categories isn't something you could exactly equate, like points on a <a class='glossary' target='_blank' title='A rating scale with a small number of discrete points in order' href='https://psyteachr.github.io/glossary/l#likert'>Likert</a> rating scale.

Different types of visualisations are good for different types of variables. 

Load the `pets` dataset and explore it with `glimpse(pets)` or `View(pets)`. This is a simulated dataset with one random factor (`id`), two categorical factors (`pet`, `country`) and three continuous variables (`score`, `age`, `weight`). 


```r
data("pets", package = "reprores")
# if you don't have the reprores package, use:
# pets <- read_csv("https://psyteachr.github.io/reprores/data/pets.csv", col_types = "cffiid")
glimpse(pets)
```

```
## Rows: 800
## Columns: 6
## $ id      <chr> "S001", "S002", "S003", "S004", "S005", "S006", "S007", "S008"…
## $ pet     <fct> dog, dog, dog, dog, dog, dog, dog, dog, dog, dog, dog, dog, do…
## $ country <fct> UK, UK, UK, UK, UK, UK, UK, UK, UK, UK, UK, UK, UK, UK, UK, UK…
## $ score   <int> 90, 107, 94, 120, 111, 110, 100, 107, 106, 109, 85, 110, 102, …
## $ age     <int> 6, 8, 2, 10, 4, 8, 9, 8, 6, 11, 5, 9, 1, 10, 7, 8, 1, 8, 5, 13…
## $ weight  <dbl> 19.78932, 20.01422, 19.14863, 19.56953, 21.39259, 21.31880, 19…
```


::: {.try data-latex=""}
Before you read ahead, come up with an example of each type of variable combination and sketch the types of graphs that would best display these data.

* 1 categorical
* 1 continuous
* 2 categorical
* 2 continuous
* 1 categorical, 1 continuous
* 3 continuous
:::


## Basic Plots

R has some basic plotting functions, but they're difficult to use and aesthetically not very nice without a fair amount of expertise. They can be useful to have a quick look at data while you're working on a script, though. The function `plot()` usually defaults to a sensible type of plot, depending on whether the arguments `x` and `y` are categorical, continuous, or missing.

<!-- Tab links -->
<div class="tab">
  <button class="tablinks" onclick="openCity(event, 'catx')">Categorical X</button>
  <button class="tablinks" onclick="openCity(event, 'catxy')">Categorical X and Y</button>
  <button class="tablinks" onclick="openCity(event, 'contxy')">Continuous X and Y</button>
</div>

<!-- Tab content -->
<div id="catx" class="tabcontent">


```r
plot(x = pets$pet)
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/plot0-1.png" alt="plot() with categorical x" width="100%" />
<p class="caption">(\#fig:plot0)plot() with categorical x</p>
</div>

</div>
<div id="catxy" class="tabcontent">


```r
plot(x = pets$pet, y = pets$score)
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/plot1-1.png" alt="plot() with categorical x and continuous y" width="100%" />
<p class="caption">(\#fig:plot1)plot() with categorical x and continuous y</p>
</div>

</div>
<div id="contxy" class="tabcontent">


```r
plot(x = pets$age, y = pets$weight)
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/plot2-1.png" alt="plot() with continuous x and y" width="100%" />
<p class="caption">(\#fig:plot2)plot() with continuous x and y</p>
</div>

</div>


The function `hist()` creates a quick histogram so you can see the distribution of your data. You can adjust how many columns are plotted with the argument `breaks`.


```r
hist(pets$score, breaks = 20)
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/hist-1.png" alt="hist()" width="100%" />
<p class="caption">(\#fig:hist)hist()</p>
</div>

## GGplots

While the functions above are nice for quick visualisations, it's hard to make pretty, publication-ready plots. The package <code class='package'>ggplot2</code> (loaded with `tidyverse`) is one of the most common packages for creating beautiful visualisations.

`ggplot2` creates plots using a "grammar of graphics" where you add <a class='glossary' target='_blank' title='The geometric style in which data are displayed, such as boxplot, density, or histogram.' href='https://psyteachr.github.io/glossary/g#geom'>geoms</a> in layers. It can be complex to understand at first, but it's very powerful once you have a mental model of how it works. 

A grammar of graphics (the "gg" in "ggplot") is a standardised way to describe the components of a graphic. <code class='package'>ggplot2</code> uses a layered grammar of graphics, in which plots are built up in a series of layers. It may be helpful to think about any picture as having multiple elements that sit semi-transparently over each other. A good analogy is old Disney movies where artists would create a background and then add moveable elements on top of the background via transparencies.

Figure\ \@ref(fig:layers) displays the evolution of a simple plot using this layered approach. First, the plot space is built (layer 1); the variables are specified (layer 2); the type of visualisation (known as a geom) that is desired for these variables is specified (layer 3) - in this case geom_violin() is called to visualise the distribution; the colours are customised (layer 4); the axis labels and ranges are edited for readability (layer 5); and a theme is applied to change the overall appearance of the plot  and the legend position is customised (layer 6).

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/layers-1.png" alt="Evolution of a layered plot" width="100%" />
<p class="caption">(\#fig:layers)Evolution of a layered plot</p>
</div>

<!-- Tab links -->
<div class="tab">
  <button class="tablinks" onclick="openCity(event, 'layer1')">Layer 1</button>
  <button class="tablinks" onclick="openCity(event, 'layer2')">Layer 2</button>
  <button class="tablinks" onclick="openCity(event, 'layer3')">Layer 3</button>
  <button class="tablinks" onclick="openCity(event, 'layer4')">Layer 4</button>
  <button class="tablinks" onclick="openCity(event, 'layer5')">Layer 5</button>
  <button class="tablinks" onclick="openCity(event, 'layer6')">Layer 6</button>
</div>

<!-- Tab content -->
<div id="layer1" class="tabcontent">

Let's start with a totally empty plot layer created by the `ggplot()` function with no arguments.


```r
ggplot()
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/ggplot-empty-1.png" alt="A plot base created by ggplot()" width="100%" />
<p class="caption">(\#fig:ggplot-empty)A plot base created by ggplot()</p>
</div>

</div>
<div id="layer2" class="tabcontent">

The first argument to `ggplot()` is the `data` table you want to plot. Let's use the `pets` data we loaded above. The second argument is the `mapping` for which columns in your data table correspond to which properties of the plot, such as the `x`-axis, the `y`-axis, line `colour` or `linetype`, point `shape`, or object `fill`. These mappings are specified by the `aes()` function. Just adding this to the `ggplot` function creates the labels and ranges for the `x` and `y` axes. They usually have sensible default values, given your data, but we'll learn how to change them later.


```r
mapping <- aes(x = pet, 
               y = score, 
               colour = country, 
               fill = country)

ggplot(data = pets, mapping = mapping)
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/ggplot-aes-1.png" alt="Empty ggplot with x and y labels" width="100%" />
<p class="caption">(\#fig:ggplot-aes)Empty ggplot with x and y labels</p>
</div>
::: {.info data-latex=""}
People usually omit the argument names and just put the `aes()` function directly as the second argument to `ggplot`. They also usually omit `x` and `y` as argument names to `aes()` (but you have to name the other properties). 
:::

</div>
<div id="layer3" class="tabcontent">

Next we can add "geoms", or plot styles. You literally add them with the `+` symbol. You can customise the appearance of a geom with arguments like `alpha` (sets transparency).


```r
ggplot(pets, aes(pet, score, colour = country, fill = country)) +
  geom_violin(alpha = 0.5)
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/ggplot-geom-1.png" alt="Violin plot with country represented by colour." width="100%" />
<p class="caption">(\#fig:ggplot-geom)Violin plot with country represented by colour.</p>
</div>

</div>
<div id="layer4" class="tabcontent">

The `scale_*` functions help you to customise the aesthetics.


```r
ggplot(pets, aes(pet, score, colour = country, fill = country)) +
  geom_violin(alpha = 0.5) +
  scale_fill_manual(values = c("orange", "orchid")) +
  scale_colour_manual(values = c("orange", "orchid"))
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/ggplot-color-1.png" alt="Customised colours." width="100%" />
<p class="caption">(\#fig:ggplot-color)Customised colours.</p>
</div>

</div>
<div id="layer5" class="tabcontent">

Further customise the image by setting the y-axis breaks and limits, and editing the labels.


```r
ggplot(pets, aes(pet, score, colour = country, fill = country)) +
  geom_violin(alpha = 0.5) +
  scale_fill_manual(values = c("orange", "orchid")) +
  scale_colour_manual(values = c("orange", "orchid")) +
  scale_y_continuous(breaks = c(50, 100, 150)) +
  coord_cartesian(ylim = c(50, 150)) +
  labs(x = "Pet type",
       y = "Score on an Important Test",
       colour = "Country of Origin",
       fill = "Country of Origin")
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/ggplot-labels-1.png" alt="Customised axis labels." width="100%" />
<p class="caption">(\#fig:ggplot-labels)Customised axis labels.</p>
</div>

</div>
<div id="layer6" class="tabcontent">

Finally, change the theme and base font size and customise the legend position.


```r
ggplot(pets, aes(pet, score, colour = country, fill = country)) +
  geom_violin(alpha = 0.5) +
  scale_fill_manual(values = c("orange", "orchid")) +
  scale_colour_manual(values = c("orange", "orchid")) +
  scale_y_continuous(breaks = c(50, 100, 150)) +
  coord_cartesian(ylim = c(50, 150)) +
  labs(x = "Pet type",
       y = "Score on an Important Test",
       colour = "Country of Origin",
       fill = "Country of Origin") +
  theme_minimal(base_size = 13) +
  theme(legend.position = c(.83, .17))
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/ggplot-theme-1.png" alt="Customised theme and legend position." width="100%" />
<p class="caption">(\#fig:ggplot-theme)Customised theme and legend position.</p>
</div>

</div>

## Common Plot Types

There are many geoms, and they can take different arguments to customise their appearance. We'll learn about some of the most common below.

### Bar plot {#geom_bar}

Bar plots are good for categorical data where you want to represent the count.


```r
ggplot(pets, aes(pet)) +
  geom_bar()
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/barplot-1.png" alt="Bar plot" width="100%" />
<p class="caption">(\#fig:barplot)Bar plot</p>
</div>

### Density plot {#geom_density}

Density plots are good for one continuous variable, but only if you have a fairly large number of observations.


```r
ggplot(pets, aes(score)) +
  geom_density()
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/density-1.png" alt="Density plot" width="100%" />
<p class="caption">(\#fig:density)Density plot</p>
</div>

You can represent subsets of a variable by assigning the category variable to the argument `group`, `fill`, or `color`. 


```r
ggplot(pets, aes(score, fill = pet)) +
  geom_density(alpha = 0.5)
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/density-grouped-1.png" alt="Grouped density plot" width="100%" />
<p class="caption">(\#fig:density-grouped)Grouped density plot</p>
</div>

::: {.try data-latex=""}
Try changing the `alpha` argument to figure out what it does.
:::

### Frequency polygons {#geom_freqpoly}

If you want the y-axis to represent count rather than density, try `geom_freqpoly()`.


```r
ggplot(pets, aes(score, color = pet)) +
  geom_freqpoly(binwidth = 5)
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/freqpoly-1.png" alt="Frequency ploygon plot" width="100%" />
<p class="caption">(\#fig:freqpoly)Frequency ploygon plot</p>
</div>

::: {.try data-latex=""}
Try changing the `binwidth` argument to 10 or 1. How do you figure out the right value?
:::

### Histogram {#geom_histogram}

Histograms are also good for one continuous variable, and work well if you don't have many observations. Set the `binwidth` to control how wide each bar is.


```r
ggplot(pets, aes(score)) +
  geom_histogram(binwidth = 5, 
                 fill = "white", 
                 color = "black")
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/histogram-1.png" alt="Histogram" width="100%" />
<p class="caption">(\#fig:histogram)Histogram</p>
</div>

::: {.info data-latex=""}
Histograms in ggplot look pretty bad unless you set the `fill` and `color`.
:::

If you show grouped histograms, you also probably want to change the default `position` argument.


```r
ggplot(pets, aes(score, fill=pet)) +
  geom_histogram(binwidth = 5, 
                 alpha = 0.5, 
                 position = "dodge")
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/histogram-grouped-1.png" alt="Grouped Histogram" width="100%" />
<p class="caption">(\#fig:histogram-grouped)Grouped Histogram</p>
</div>

::: {.try data-latex=""}
Try changing the `position` argument to "identity", "fill", "dodge", or "stack".
:::

### Column plot {#geom_col}

Column plots are the worst way to represent grouped continuous data, but also one of the most common. If your data are already aggregated (e.g., you have rows for each group with columns for the mean and standard error), you can use `geom_bar` or `geom_col` and `geom_errorbar` directly. If not, you can use the function `stat_summary` to calculate the mean and standard error and send those numbers to the appropriate geom for plotting.


```r
ggplot(pets, aes(pet, score, fill=pet)) +
  stat_summary(fun = mean, geom = "col", alpha = 0.5) + 
  stat_summary(fun.data = mean_se, 
               geom = "errorbar",
               width = 0.25) +
  coord_cartesian(ylim = c(80, 120))
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/colplot-statsum-1.png" alt="Column plot" width="100%" />
<p class="caption">(\#fig:colplot-statsum)Column plot</p>
</div>

::: {.try data-latex=""}
Try changing the values for `coord_cartesian`. What does this do?
:::

### Boxplot {#geom_boxplot}

Boxplots are great for representing the distribution of grouped continuous variables. They fix most of the problems with using bar/column plots for continuous data.


```r
ggplot(pets, aes(pet, score, fill=pet)) +
  geom_boxplot(alpha = 0.5)
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/boxplot-1.png" alt="Box plot" width="100%" />
<p class="caption">(\#fig:boxplot)Box plot</p>
</div>

### Violin plot {#geom_violin}

Violin pots are like sideways, mirrored density plots. They give even more information than a boxplot about distribution and are especially useful when you have non-normal distributions.


```r
ggplot(pets, aes(pet, score, fill=pet)) +
  geom_violin(draw_quantiles = .5,
              trim = FALSE, 
              alpha = 0.5)
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/violin-1.png" alt="Violin plot" width="100%" />
<p class="caption">(\#fig:violin)Violin plot</p>
</div>

::: {.try data-latex=""}
Try changing the `quantile` argument. Set it to a vector of the numbers 0.1 to 0.9 in steps of 0.1.
:::

### Vertical intervals {#vertical_intervals}

Boxplots and violin plots don't always map well onto inferential stats that use the mean. You can represent the mean and standard error or any other value you can calculate.

Here, we will create a table with the means and standard errors for two groups. We'll learn how to calculate this from raw data in the chapter on [data wrangling](#dplyr). We also create a new object called `gg` that sets up the base of the plot. 


```r
dat <- tibble(
  group = c("A", "B"),
  mean = c(10, 20),
  se = c(2, 3)
)
gg <- ggplot(dat, aes(group, mean, 
                      ymin = mean-se, 
                      ymax = mean+se))
```

The trick above can be useful if you want to represent the same data in different ways. You can add different geoms to the base plot without having to re-type the base plot code.


```r
cb <- gg + geom_crossbar() + ggtitle("geom_crossbar()")
eb <- gg + geom_errorbar() + ggtitle("geom_errorbar()")
lr <- gg + geom_linerange() + ggtitle("geom_linerange()")
pr <- gg + geom_pointrange() + ggtitle("geom_pointrange()")

cb + eb + lr + pr # combine with patchwork package
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/geom-crossbar-1.png" alt="Four different styles of vertical interval" width="100%" />
<p class="caption">(\#fig:geom-crossbar)Four different styles of vertical interval</p>
</div>


You can also use the function `stats_summary` to calculate mean, standard error, or any other value for your data and display it using any geom. 


```r
ggplot(pets, aes(pet, score, color=pet)) +
  stat_summary(fun.data = mean_se, geom = "crossbar") +
  stat_summary(fun.min = function(x) mean(x) - sd(x),
               fun.max = function(x) mean(x) + sd(x),
               geom = "errorbar", width = 0) +
  theme(legend.position = "none") # gets rid of the legend
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/vertint-statssum-1.png" alt="Vertical intervals with stats_summary()" width="100%" />
<p class="caption">(\#fig:vertint-statssum)Vertical intervals with stats_summary()</p>
</div>

### Scatter plot {#geom_point}

Scatter plots are a good way to represent the relationship between two continuous variables.


```r
ggplot(pets, aes(weight, score, color = pet)) +
  geom_point()
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/scatter-1.png" alt="Scatter plot using geom_point()" width="100%" />
<p class="caption">(\#fig:scatter)Scatter plot using geom_point()</p>
</div>

### Line graph {#geom_smooth}

You often want to represent the relationship as a single line.


```r
ggplot(pets, aes(weight, score, color = pet)) +
  geom_smooth(formula = y ~ x, method="lm")
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/smooth-1.png" alt="Line plot using geom_smooth()" width="100%" />
<p class="caption">(\#fig:smooth)Line plot using geom_smooth()</p>
</div>

::: {.try data-latex=""}
What are some other options for the `method` argument to `geom_smooth`? When might you want to use them?
:::


<div class='webex-solution'><button>Bonus: Non-Linear Plots</button>


::: {.info data-latex=""}
You can plot functions other than the linear `y ~ x`. The code below creates a data table where `x` is 101 values between -10 and 10. and `y` is `x` squared plus `3*x` plus `1`. You'll probably recognise this from algebra as the quadratic equation. You can set the `formula` argument in `geom_smooth` to a quadratic formula (`y ~ x + I(x^2)`) to fit a quadratic function to the data.


```r
quad <- tibble(
  x = seq(-10, 10, length.out = 101),
  y = x^2 + 3*x + 1
)

ggplot(quad, aes(x, y)) +
  geom_point() +
  geom_smooth(formula = y ~ x + I(x^2), 
              method="lm")
```

<div class="figure" style="text-align: center">
<img src="03-ggplot_files/figure-html/quadratic-1.png" alt="Fitting quadratic functions" width="100%" />
<p class="caption">(\#fig:quadratic)Fitting quadratic functions</p>
</div>
:::


</div>


## Customisation

### Size and Position {#custom-size}

You can change the size, aspect ratio and position of plots in an R Markdown document in the setup chunk.


```r
knitr::opts_chunk$set(
  fig.width  = 8, # figures default to 8 inches wide
  fig.height = 5, # figures default to 5 inches tall
  fig.path   = 'images/', # figures saved in images directory
  out.width = "90%", # images take up 90% of page width
  fig.align = 'center' # centre images
)
```

You can change defaults for any single image using <a class='glossary' target='_blank' title='A section of code in an R Markdown file' href='https://psyteachr.github.io/glossary/c#chunk'>chunk</a> options.

<div class='verbatim'><pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;{r fig-pet1, fig.width=10, fig.height=3, out.width="100%", fig.align="center"}</code></pre>

```r
ggplot(pets, aes(weight, score, color = pet)) +
  geom_smooth(formula = y~x, method = lm)
```

<pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;</code></pre></div>

<div class="figure" style="text-align: center">
<img src="images/fig-chunk-example1-out-1.png" alt="10x3 inches at 100% width centre aligned." width="100%" />
<p class="caption">(\#fig:fig-chunk-example1-out)10x3 inches at 100% width centre aligned.</p>
</div>

<div class='verbatim'><pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;{r fig-pet2, fig.width=5, fig.height=3, out.width="50%", fig.align="left"}</code></pre>

```r
ggplot(pets, aes(weight, score, color = pet)) +
  geom_smooth(formula = y~x, method = lm)
```

<pre class='sourceCode r'><code class='sourceCode R'>&#96;&#96;&#96;</code></pre></div>

<div class="figure" style="text-align: left">
<img src="images/fig-chunk-example2-out-1.png" alt="5x3 inches at 50% width aligned left." width="50%" />
<p class="caption">(\#fig:fig-chunk-example2-out)5x3 inches at 50% width aligned left.</p>
</div>

### Labels {#custom-labels}

You can set custom titles and axis labels in a few different ways.


```r
ggplot(pets, aes(weight, score, color = pet)) +
  geom_smooth(formula = y ~ x, method="lm") +
  labs(title = "Pet Score by Weight and Type",
       x = "Weight (in kg)",
       y = "Pet Score",
       color = "Pet Type")
```

<div class="figure" style="text-align: center">
<img src="images/line-labels1-1.png" alt="Set custom labels with labs()" width="90%" />
<p class="caption">(\#fig:line-labels1)Set custom labels with labs()</p>
</div>


```r
ggplot(pets, aes(weight, score, color = pet)) +
  geom_smooth(formula = y ~ x, method="lm") +
  ggtitle("Pet Score by Weight and Type") +
  xlab("Weight (in kg)") +
  ylab("Pet Score")
```

<div class="figure" style="text-align: center">
<img src="images/line-labels2-1.png" alt="Set custom labels with individual functions" width="90%" />
<p class="caption">(\#fig:line-labels2)Set custom labels with individual functions</p>
</div>

The functions <code><span><span class='fu'>labs</span><span class='op'>(</span><span class='op'>)</span></span></code>, <code><span><span class='fu'>xlab</span><span class='op'>(</span><span class='op'>)</span></span></code>, and <code><span><span class='fu'>ylab</span><span class='op'>(</span><span class='op'>)</span></span></code> are convenient when you just want to change a label name, but the `scale_{aesthetic}_{type}` functions are worth learning because they let you customise many things about any aesthetic property (e.g., `x`, `y`, `colour`, `fill`, `shape`, `linetype`), as long as you choose the correct type (usually `continuous` or `discrete`, but there are also special scale functions for other data types like dates).


```r
ggplot(pets, aes(weight, score, color = pet)) +
  geom_smooth(formula = y ~ x, method="lm") +
  ggtitle("Pet Score by Weight and Type") +
  scale_x_continuous(name = "Weight (in kg)", 
                     breaks = seq(0, 26, 2),
                     minor_breaks = NULL, 
                     position = "top") +
  scale_y_continuous(name = "Pet Score", 
                     n.breaks = 16, 
                     trans = "reverse",
                     limits = c(150, 0)) +
  scale_color_discrete(name = "Pet Type", 
                       labels = c("Dogs", "Cats", "Ferrets"), 
                       type = c("purple", "green", "orange"))
```

<div class="figure" style="text-align: center">
<img src="images/line-labels3-1.png" alt="Set custom labels with scale functions" width="90%" />
<p class="caption">(\#fig:line-labels3)Set custom labels with scale functions</p>
</div>

::: {.try data-latex=""}
Use the help on the scale functions above to learn about the possible arguments. See what happens when you change the arguments above.
:::

### Colours {#custom-colours}

You can set custom values for colour and fill using the `scale_{aesthetic}_{type}` functions like `scale_colour_manual()` or `scale_fill_manual()`. 


```r
ggplot(pets, aes(pet, score, colour = pet, fill = pet)) +
  geom_violin() +
  scale_color_manual(values = c("darkgreen", "dodgerblue", "orange")) +
  scale_fill_manual(values = c("#CCFFCC", "#BBDDFF", "#FFCC66"))
```

<div class="figure" style="text-align: center">
<img src="images/line-labels-1.png" alt="Set custom colour" width="90%" />
<p class="caption">(\#fig:line-labels)Set custom colour</p>
</div>

The [Colours chapter in Cookbook for R](http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/) has many more ways to customise colour.

### Themes {#themes}

GGplot comes with several additional themes and the ability to fully customise your theme. Type `?theme` into the console to see the full list. Other packages such as `cowplot` also have custom themes. You can add a custom theme to the end of your ggplot object and specify a new `base_size` to make the default fonts and lines larger or smaller.


```r
ggplot(pets, aes(weight, score, color = pet)) +
  geom_smooth(formula = y ~ x, method="lm") +
  theme_minimal(base_size = 18)
```

<div class="figure" style="text-align: center">
<img src="images/themes-1.png" alt="Minimal theme with 18-point base font size" width="90%" />
<p class="caption">(\#fig:themes)Minimal theme with 18-point base font size</p>
</div>

It's more complicated, but you can fully customise your theme with `theme()`. You can save this to an object and add it to the end of all of your plots to make the style consistent. Alternatively, you can set the theme at the top of a script with `theme_set()` and this will apply to all subsequent ggplot plots. 





```r
# always start with a base theme that is closest to your desired theme
vampire_theme <- theme_dark() +
  theme(
    rect = element_rect(fill = "black"),
    panel.background = element_rect(fill = "black"),
    text = element_text(size = 20, colour = "white"),
    axis.text = element_text(size = 16, colour = "grey70"),
    line = element_line(colour = "white", size = 2),
    panel.grid = element_blank(),
    axis.line = element_line(colour = "white"),
    axis.ticks = element_blank(),
    legend.position = "top"
  )

theme_set(vampire_theme)

ggplot(pets, aes(weight, score, color = pet)) +
  geom_smooth(formula = y ~ x, method="lm")
```

<div class="figure" style="text-align: center">
<img src="images/custom-themes-1.png" alt="Custom theme" width="90%" />
<p class="caption">(\#fig:custom-themes)Custom theme</p>
</div>




### Save as file {#ggsave}

You can save a ggplot using `ggsave()`. It saves the last ggplot you made, by default, but you can specify which plot you want to save if you assigned that plot to a variable.

You can set the `width` and `height` of your plot. The default units are inches, but you can change the `units` argument to "in", "cm", or "mm".



```r
box <- ggplot(pets, aes(pet, score, fill=pet)) +
  geom_boxplot(alpha = 0.5)

violin <- ggplot(pets, aes(pet, score, fill=pet)) +
  geom_violin(alpha = 0.5)

ggsave("demog_violin_plot.png", width = 5, height = 7)

ggsave("demog_box_plot.jpg", plot = box, width = 5, height = 7)
```

::: {.info data-latex=""}
The file type is set from the filename suffix, or by 
specifying the argument `device`, which can take the following values: 
"eps", "ps", "tex", "pdf", "jpeg", "tiff", "png", "bmp", "svg" or "wmf".
:::

## Combination Plots {#combo_plots}

### Violinbox plot

A combination of a violin plot to show the shape of the distribution and a boxplot to show the median and interquartile ranges can be a very useful visualisation.


```r
ggplot(pets, aes(pet, score, fill = pet)) +
  geom_violin(show.legend = FALSE) + 
  geom_boxplot(width = 0.2, fill = "white", 
               show.legend = FALSE)
```

<div class="figure" style="text-align: center">
<img src="images/violinbox-1.png" alt="Violin-box plot" width="90%" />
<p class="caption">(\#fig:violinbox)Violin-box plot</p>
</div>

::: {.info data-latex=""}
Set the `show.legend` argument to `FALSE` to hide the legend. We do this here because the x-axis already labels the pet types.
:::

### Violin-point-range plot

You can use `stat_summary()` to superimpose a point-range plot showing the mean ± 1 SD. You'll learn how to write your own functions in the lesson on [Iteration and Functions](#func).


```r
ggplot(pets, aes(pet, score, fill=pet)) +
  geom_violin(trim = FALSE, alpha = 0.5) +
  stat_summary(
    fun = mean,
    fun.max = function(x) {mean(x) + sd(x)},
    fun.min = function(x) {mean(x) - sd(x)},
    geom="pointrange"
  )
```

<div class="figure" style="text-align: center">
<img src="images/stat-summary-1.png" alt="Point-range plot using stat_summary()" width="90%" />
<p class="caption">(\#fig:stat-summary)Point-range plot using stat_summary()</p>
</div>

### Violin-jitter plot

If you don't have a lot of data points, it's good to represent them individually. You can use `geom_jitter` to do this.


```r
# sample_n chooses 50 random observations from the dataset
ggplot(sample_n(pets, 50), aes(pet, score, fill=pet)) +
  geom_violin(
    trim = FALSE,
    draw_quantiles = c(0.25, 0.5, 0.75), 
    alpha = 0.5
  ) + 
  geom_jitter(
    width = 0.15, # points spread out over 15% of available width
    height = 0, # do not move position on the y-axis
    alpha = 0.5, 
    size = 3
  )
```

<div class="figure" style="text-align: center">
<img src="images/violin-jitter-1.png" alt="Violin-jitter plot" width="90%" />
<p class="caption">(\#fig:violin-jitter)Violin-jitter plot</p>
</div>

### Scatter-line graph

If your graph isn't too complicated, it's good to also show the individual data points behind the line.


```r
ggplot(sample_n(pets, 50), aes(age, weight, colour = pet)) +
  geom_point() +
  geom_smooth(formula = y ~ x, method="lm")
```

<div class="figure" style="text-align: center">
<img src="images/scatter-line-1.png" alt="Scatter-line plot" width="90%" />
<p class="caption">(\#fig:scatter-line)Scatter-line plot</p>
</div>

### Facets

You may want to replicate your plot for each level of a categorical variable. The `facet` functions make this easy. If you have a single category to facet over, such as country, you can use `facet_wrap()`, which makes a plot for each level.


```r
ggplot(pets, aes(pet, score, fill = pet)) +
  geom_violin(show.legend = FALSE) + 
  facet_wrap(facets = vars(country))
```

<div class="figure" style="text-align: center">
<img src="images/facet-wrap-1.png" alt="Facetted plot, facetting by country." width="90%" />
<p class="caption">(\#fig:facet-wrap)Facetted plot, facetting by country.</p>
</div>

::: {.warning}
You can't just use unquoted column names for the `facets` argument; you have to specify them using the `vars()` function. You may see a common shortcut notation using the tilde that is equivalent: `facet_wrap(~country)`.
:::

If you have many levels, the plots will "wrap" around. The function makes a best guess at what will look good, but you can also specify how many rows or columns the resulting plot should have by setting the arguments `ncol` or `nrow`. 


```r
ggplot(pets, aes(pet, score, fill = pet)) +
  geom_violin(show.legend = FALSE) + 
  facet_wrap(facets = vars(age), nrow = 3)
```

<div class="figure" style="text-align: center">
<img src="images/facet-wrap2-1.png" alt="Facetted plot, facetting by age" width="90%" />
<p class="caption">(\#fig:facet-wrap2)Facetted plot, facetting by age</p>
</div>

If you want to make sub-plots for crossed factors, you can use `facet_grid()`


```r
ggplot(pets, aes(weight, score)) +
  geom_point(alpha = 0.5) +
  geom_smooth(formula = y ~ x, method="lm") + 
  facet_grid(rows = vars(pet), cols = vars(country))
```

<div class="figure" style="text-align: center">
<img src="images/facet-grid-1.png" alt="Facetted plot" width="90%" />
<p class="caption">(\#fig:facet-grid)Facetted plot</p>
</div>

```r
  # facet_grid(pet~country) # an alternative shortcut way to specify the rows and columns
```

::: {.try}
Look at the help for `facet_grid()` and see what happens when you change the default values of arguments such as `margin`, `scales`, `as.table` and `switch`. 
:::


### Grid of plots {#plot_grid}

You can use the [`patchwork`](https://patchwork.data-imaginist.com/) package to easily make grids of different graphs. First, you have to assign each plot a name. 


```r
gg <- ggplot(pets, aes(pet, score, colour = pet))
nolegend <- theme(legend.position = 0)

vp <- gg + geom_violin(alpha = 0.5) + nolegend +
  ggtitle("Violin Plot")
bp <- gg + geom_boxplot(alpha = 0.5) + nolegend +
  ggtitle("Box Plot")
cp <- gg + stat_summary(fun = mean, geom = "col", fill = "white") + nolegend +
  ggtitle("Column Plot")
dp <- ggplot(pets, aes(score, colour = pet)) + 
  geom_density() + nolegend +
  ggtitle("Density Plot")
```

Then you add all the plots together.


```r
vp + bp + cp + dp
```

<div class="figure" style="text-align: center">
<img src="images/patchwork-add-1.png" alt="Default grid of plots" width="90%" />
<p class="caption">(\#fig:patchwork-add)Default grid of plots</p>
</div>

You can use `+`, `|`, `/`, and parentheses to customise your layout.


```r
(vp | bp | cp) / dp
```

<div class="figure" style="text-align: center">
<img src="images/patchwork-layout-1.png" alt="Custom plot layout." width="90%" />
<p class="caption">(\#fig:patchwork-layout)Custom plot layout.</p>
</div>

You can alter the plot layout to control the number and widths of plots per row or column, and add annotation. 


```r
vp + bp + cp + 
  plot_layout(nrow = 1, width = c(1,2,1)) +
  plot_annotation(title = "Pet Scores",
                  subtitle = "Three plots visualising the same data",
                  tag_levels = "a")
```

<div class="figure" style="text-align: center">
<img src="images/patchwork-annotate-1.png" alt="Plot annotation." width="90%" />
<p class="caption">(\#fig:patchwork-annotate)Plot annotation.</p>
</div>

::: {.try data-latex=""}
Check the help for `plot_layout()` and plot_annotation()` to see what else you can do with them.
:::


## Overlapping Discrete Data {#overlap}

### Reducing Opacity 

You can deal with overlapping data points (very common if you're using Likert scales) by reducing the opacity of the points. You need to use trial and error to adjust these so they look right.


```r
ggplot(pets, aes(age, score, colour = pet)) +
  geom_point(alpha = 0.25) +
  geom_smooth(formula = y ~ x, method="lm")
```

<div class="figure" style="text-align: center">
<img src="images/overlap-alpha-1.png" alt="Deal with overlapping data using transparency" width="90%" />
<p class="caption">(\#fig:overlap-alpha)Deal with overlapping data using transparency</p>
</div>

### Proportional Dot Plots {#geom_count}

Or you can set the size of the dot proportional to the number of overlapping observations using `geom_count()`.


```r
ggplot(pets, aes(age, score, colour = pet)) +
  geom_count()
```

<div class="figure" style="text-align: center">
<img src="images/overlap-size-1.png" alt="Deal with overlapping data using geom_count()" width="90%" />
<p class="caption">(\#fig:overlap-size)Deal with overlapping data using geom_count()</p>
</div>

Alternatively, you can transform your data (we will learn to do this in the [data wrangling](#dplyr) chapter) to create a count column and use the count to set the dot colour.


```r
pets %>%
  group_by(age, score) %>%
  summarise(count = n(), .groups = "drop") %>%
  ggplot(aes(age, score, color=count)) +
  geom_point(size = 2) +
  scale_color_viridis_c()
```

<div class="figure" style="text-align: center">
<img src="images/overlap-colour-1.png" alt="Deal with overlapping data using dot colour" width="90%" />
<p class="caption">(\#fig:overlap-colour)Deal with overlapping data using dot colour</p>
</div>


::: {.info data-latex=""}
The [viridis package](https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html) changes the colour themes to be easier to read by people with colourblindness and to print better in greyscale. Viridis is built into `ggplot2` since v3.0.0. It uses `scale_colour_viridis_c()` and `scale_fill_viridis_c()` for continuous variables and `scale_colour_viridis_d()` and `scale_fill_viridis_d()` for discrete variables.
:::

## Overlapping Continuous Data

Even if the variables are continuous, overplotting might obscure any relationships if you have lots of data.


```r
ggplot(pets, aes(age, score)) +
  geom_point()
```

<div class="figure" style="text-align: center">
<img src="images/overplot-point-1.png" alt="Overplotted data" width="90%" />
<p class="caption">(\#fig:overplot-point)Overplotted data</p>
</div>

### 2D Density Plot {#geom_density2d}
Use `geom_density2d()` to create a contour map.


```r
ggplot(pets, aes(age, score)) +
  geom_density2d()
```

<div class="figure" style="text-align: center">
<img src="images/density2d-1.png" alt="Contour map with geom_density2d()" width="90%" />
<p class="caption">(\#fig:density2d)Contour map with geom_density2d()</p>
</div>

You can use `geom_density2d_filled()` to create a heatmap-style density plot.


```r
ggplot(pets, aes(age, score)) +
  geom_density2d_filled(n = 5, h = 10)
```

<div class="figure" style="text-align: center">
<img src="images/density2d-fill-1.png" alt="Heatmap-density plot" width="90%" />
<p class="caption">(\#fig:density2d-fill)Heatmap-density plot</p>
</div>

::: {.try data-latex=""}
Try `geom_density2d_filled(n = 5, h = 10)` instead. Play with different values of `n` and `h` and try to guess what they do.
:::


### 2D Histogram {#geom_bin2d}

Use `geom_bin2d()` to create a rectangular heatmap of bin counts. Set the `binwidth` to the x and y dimensions to capture in each box.


```r
ggplot(pets, aes(age, score)) +
  geom_bin2d(binwidth = c(1, 5))
```

<div class="figure" style="text-align: center">
<img src="images/bin2d-1.png" alt="Heatmap of bin counts" width="90%" />
<p class="caption">(\#fig:bin2d)Heatmap of bin counts</p>
</div>

### Hexagonal Heatmap {#geom_hex}

Use `geomhex()` to create a hexagonal heatmap of bin counts. Adjust the `binwidth`, `xlim()`, `ylim()` and/or the figure dimensions to make the hexagons more or less stretched.


```r
ggplot(pets, aes(age, score)) +
  geom_hex(binwidth = c(1, 5))
```

<div class="figure" style="text-align: center">
<img src="images/overplot-hex-1.png" alt="Hexagonal heatmap of bin counts" width="90%" />
<p class="caption">(\#fig:overplot-hex)Hexagonal heatmap of bin counts</p>
</div>

### Correlation Heatmap {#geom_tile}

I've included the code for creating a correlation matrix from a table of variables, but you don't need to understand how this is done yet. We'll cover `mutate()` and `gather()` functions in the [dplyr](#dplyr) and [tidyr](#tidyr) lessons.


```r
heatmap <- pets %>%
  select_if(is.numeric) %>% # get just the numeric columns
  cor() %>% # create the correlation matrix
  as_tibble(rownames = "V1") %>% # make it a tibble
  gather("V2", "r", 2:ncol(.)) # wide to long (V2)
```

Once you have a correlation matrix in the correct (long) format, it's easy to make a heatmap using `geom_tile()`.


```r
ggplot(heatmap, aes(V1, V2, fill=r)) +
  geom_tile() +
  scale_fill_viridis_c()
```

<div class="figure" style="text-align: center">
<img src="images/heatmap-1.png" alt="Heatmap using geom_tile()" width="90%" />
<p class="caption">(\#fig:heatmap)Heatmap using geom_tile()</p>
</div>


## Glossary {#glossary-ggplot}

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> term </th>
   <th style="text-align:left;"> definition </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> [chunk](https://psyteachr.github.io/glossary/c.html#chunk){class="glossary" target="_blank"} </td>
   <td style="text-align:left;"> A section of code in an R Markdown file </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [continuous](https://psyteachr.github.io/glossary/c.html#continuous){class="glossary" target="_blank"} </td>
   <td style="text-align:left;"> Data that can take on any values between other existing values. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [discrete](https://psyteachr.github.io/glossary/d.html#discrete){class="glossary" target="_blank"} </td>
   <td style="text-align:left;"> Data that can only take certain values, such as integers. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [geom](https://psyteachr.github.io/glossary/g.html#geom){class="glossary" target="_blank"} </td>
   <td style="text-align:left;"> The geometric style in which data are displayed, such as boxplot, density, or histogram. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [likert](https://psyteachr.github.io/glossary/l.html#likert){class="glossary" target="_blank"} </td>
   <td style="text-align:left;"> A rating scale with a small number of discrete points in order </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [nominal](https://psyteachr.github.io/glossary/n.html#nominal){class="glossary" target="_blank"} </td>
   <td style="text-align:left;"> Categorical variables that don't have an inherent order, such as types of animal. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> [ordinal](https://psyteachr.github.io/glossary/o.html#ordinal){class="glossary" target="_blank"} </td>
   <td style="text-align:left;"> Discrete variables that have an inherent order, such as level of education or dislike/like. </td>
  </tr>
</tbody>
</table>



## Further Resources {#resources-ggplot}

* [Data visualisation using R, for researchers who don't use R](https://psyarxiv.com/4huvw/)
* [Chapter 3: Data Visualisation](http://r4ds.had.co.nz/data-visualisation.html) of *R for Data Science*
* [ggplot2 cheat sheet](https://github.com/rstudio/cheatsheets/raw/master/data-visualization-2.1.pdf)
* [ggplot2 FAQs](https://ggplot2.tidyverse.org/articles/)
* [Chapter 28: Graphics for communication](http://r4ds.had.co.nz/graphics-for-communication.html) of *R for Data Science*
* [Look at Data](http://socviz.co/look-at-data.html) from [Data Vizualization for Social Science](http://socviz.co/)
* [Hack Your Data Beautiful](https://psyteachr.github.io/hack-your-data/) workshop by University of Glasgow postgraduate students
* [Graphs](http://www.cookbook-r.com/Graphs) in *Cookbook for R*
* [ggplot2 documentation](https://ggplot2.tidyverse.org/reference/)
* [The R Graph Gallery](http://www.r-graph-gallery.com/) (this is really useful)
* [Top 50 ggplot2 Visualizations](http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html)
* [R Graphics Cookbook](http://www.cookbook-r.com/Graphs/) by Winston Chang
* [ggplot extensions](https://www.ggplot2-exts.org/)
* [plotly](https://plot.ly/ggplot2/) for creating interactive graphs
