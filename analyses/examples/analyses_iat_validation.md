iat\_validation
================
William Hall
June 10, 2016

Overview
--------

For both the engineering sample (EES) and the grad sample (GSS) I examined the split half reliability and outlying responses. Overall the grad data looks to have less problematic responding than the engineering sample. At the end of the document I flag possible cases that we might exclude in the engineering sample.

IAT scoring algorithm
---------------------

The brief IAT was scored according to the best practices described in [Nosek et al., (2014)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4259300/):

-   Remove trials &gt;10000 milliseconds
-   Remove 1st four trials of each response block
-   Retain error trials
-   Recode &lt;400 ms to 400 ms and &gt;2000 ms to 2000 ms
-   Compute D separately for each pair of two consecutive blocks separately, and then average
-   Remove participants with &gt;10% fast responses

Note that Nosek et al., (2014) didn't find that removing participants with a high percentage of error rates improved the sensitivity of the d-scores so they don't recommend doing that. Instead they found that removing people with a &gt;10% responses that were less than 300ms was a better choice, and that is what I did, along with the other recommendations.

Split half reliability
----------------------

The first thing I did is, for each study, split the task in two and compute a d-score for both halves and the look at the correlation between the two halves. The split-half reliability looked good for both studies:

    ## Joining by: c("subject", "block_type")

| study | r    | p.value   | conf.low | conf.high |
|:------|:-----|:----------|:---------|:----------|
| ees   | 0.22 | &lt; .001 | 0.11     | 0.34      |
| gss   | 0.23 | .012      | 0.05     | 0.39      |

Outliers
--------

### Reaction times

Next, I wanted to see if there were participants whose reaction times were on average outliers. In the plot below, the black points are individual trial reaction times, and each red dot represents a participants' mean reaction time. You can see that the grad data looks pretty clean, but in the EES data one person looks potentially problematic.

![](analyses_iat_validation_files/figure-markdown_github/unnamed-chunk-3-1.png)

### Counts of winsorized reaction times

Another way to look for participants with problematic reaction times is to count the number of winsorized reaction times for each participant. The plot below shows these counts (note that these plots don't include people with zero winsorized rts). You can see that the EES data has one person with a lot of reaction times that were set to 400ms or 2000ms; the grad data looks ok.

    ## Joining by: "subject"

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](analyses_iat_validation_files/figure-markdown_github/unnamed-chunk-4-1.png)

### Error rates

Next, I plotted the proportion of correct responses (1 = 100% correct, 0 = 0% correct). You can see that there is one person in the EES data that has a high proportion of error rates (around 50%).

![](analyses_iat_validation_files/figure-markdown_github/unnamed-chunk-5-1.png)

Tests for study differences
---------------------------

Finally, I tested whether there were between study differences on the mean reaction times, number of winsorized responses, and error rates. These anlyses showed that there were significant differences for mean rts and the counts for winsorized responses; in both cases, the EES data shows evidence of more problematic responding than the grad data.

    ## Joining by: study, subject
    ## Joining by: study, subject

![](analyses_iat_validation_files/figure-markdown_github/unnamed-chunk-6-1.png)

| var\_name     | estimate | std.error | statistic | p.value   | conf.low | conf.high |
|:--------------|:---------|:----------|:----------|:----------|:---------|:----------|
| latency       | -61.93   | 4.70      | -13.19    | &lt; .001 | -71.14   | -52.72    |
| perc\_correct | 0.00     | 0.00      | 0.21      | .84       | -0.00    | 0.00      |
| n\_outliers   | -0.64    | 0.06      | -11.30    | &lt; .001 | -0.75    | -0.53     |

Identifying problematic participants
------------------------------------

The following IDs might be worth exploring: 8344, 8108, and 8349. 8108 and 8344 seem the most egregious to me. 8344 made a lot of mistakes but did so with pretty slow reaction times -- hence why the remained in the data. 8108 didn't make too many mistakes but responded very slowly throughout the task.

### Outlying reaction times

Top five reaction times, sorted in descending order:

|  subject|  mean\_latency|
|--------:|--------------:|
|     8108|       1944.969|
|     8349|       1538.375|
|     8355|       1484.484|
|     8093|       1425.250|
|     8113|       1425.125|

### Outlying counts of winsorized reaction times

Top five winsorized counts, sorted in descending order:

|  subject|  n\_outliers| study |
|--------:|------------:|:------|
|     8108|           50| ees   |
|     8355|           22| ees   |
|     8113|           19| ees   |
|     8068|           16| ees   |
|     8344|           16| ees   |

### Outlying error rates

Top five error rates, sorted in ascending order:

| study |  subject|  perc\_correct|
|:------|--------:|--------------:|
| ees   |     8344|       0.515625|
| ees   |     8093|       0.671875|
| ees   |     8270|       0.703125|
| ees   |     8309|       0.750000|
| ees   |     8108|       0.765625|

Compatible vs. incompatible blocks
----------------------------------

Plot of reactime times of compatible and incompatible blocks, split by study. The red dot indicates the mean reaction time.

![](analyses_iat_validation_files/figure-markdown_github/unnamed-chunk-10-1.png)

I fit a mixed model ANOVA with blocktype varying within subjects and study varying between subjects.

### Overall ANOVA

| term            |     Sum Sq|    Mean Sq|  F value|
|:----------------|----------:|----------:|--------:|
| study           |   708639.1|   708639.1|     9.01|
| blockcode       |  3744877.5|  3744877.5|    47.61|
| study:blockcode |   507042.2|   507042.2|     6.45|

### Pairwise contrasts

Pairwise contrasts show that the grad sample generally had faster RTs than the workplace sample, but the grad sample had less stereotypical associations (i.e. the difference between participants congurent and incongruent RTs is smaller in the grad (vs. workplace) sample)

| contrast                            |  estimate|     SE|  z.ratio|  p.value|
|:------------------------------------|---------:|------:|--------:|--------:|
| ees,compatible - gss,compatible     |     43.76|  21.84|     2.00|     0.05|
| ees,compatible - ees,incompatible   |    -57.07|   7.99|    -7.14|     0.00|
| ees,compatible - gss,incompatible   |     23.03|  21.84|     1.05|     0.29|
| gss,compatible - ees,incompatible   |   -100.83|  21.84|    -4.62|     0.00|
| gss,compatible - gss,incompatible   |    -20.72|  11.88|    -1.74|     0.08|
| ees,incompatible - gss,incompatible |     80.11|  21.84|     3.67|     0.00|
