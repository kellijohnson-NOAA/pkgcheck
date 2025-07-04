#' Check that 'srr' documentation for statistics pacakges is complete.
#'
#' Procedures for preparing and submitting statistical packages are described in
#' [our "*Stats Dev Guide*"](https://stats-devguide.ropensci.org). Statistical
#' packages must use [the 'srr' (software review roclets)
#' package](https://docs.ropensci.org/srr) to document compliance with our
#' statistical standards. This check uses [the `srr::srr_stats_pre_submit()`
#' function](https://docs.ropensci.org/srr/reference/srr_stats_pre_submit.html)
#' to confirm that compliance with all relevant standards has been documented.
#'
#' @noRd
pkgchk_srr_okay <- function (checks) {

    checks$info$srr$okay
}

output_pkgchk_srr_okay <- function (checks) {

    srr_okay <- "srr" %in% names (checks$info)
    if (srr_okay) {
        srr_okay <- checks$info$srr$okay
    }
    out <- list (
        check_pass = srr_okay,
        summary = "",
        print = ""
    )
    if (out$check_pass) {
        out$summary <- paste0 (
            "This is a statistical package which ",
            "complies with all applicable standards"
        )
    }

    return (out)
}

output_pkgchk_srr_todo <- function (checks) {

    out <- list (
        check_pass = !any (grepl (
            "still has TODO standards",
            checks$info$srr$message
        )),
        summary = grep ("still has TODO standards",
            checks$info$srr$message,
            value = TRUE
        ),
        print = ""
    )

    return (out)
}

output_pkgchk_srr_missing <- function (checks) {

    srr <- checks$info$srr

    check_pass <- !any (grepl (
        "following standards \\[v.*\\] are missing",
        srr$message
    ))

    out <- list (
        check_pass = check_pass,
        summary = "",
        print = ""
    )

    if (!out$check_pass) {
        out$summary <- "Some statistical standards are missing"
    }

    return (out)
}

output_pkgchk_srr_most_in_one_file <- function (checks) {

    srr <- checks$info$srr

    warn_msg <- "should be documented in"
    check_pass <- !any (grepl (warn_msg, srr$message))

    out <- list (
        check_pass = check_pass,
        summary = grep (warn_msg, srr$message, value = TRUE),
        print = ""
    )

    return (out)
}

print_srr <- function (x) {

    cli::cli_h2 ("rOpenSci Statistical Standards")
    ncats <- length (x$info$srr$categories) # nolint
    cli::cli_alert_info ("The package is in the following {ncats} categor{?y/ies}:") # nolint
    cli::cli_li (x$info$srr$categories)
    cli::cli_text ("")
    cli::cli_alert_info ("Compliance with rOpenSci statistical standards:")

    while (!nzchar (x$info$srr$message [1])) {
        x$info$srr$message <- x$info$srr$message [-1]
    }

    if (x$info$srr$okay) {
        cli::cli_alert_success (x$info$srr$message)
    } else {
        cli::cli_alert_danger (x$info$srr$message [1])
        if (length (x$info$srr$message) > 1) {
            m <- x$info$srr$message
            if (grepl ("missing from your code", m [1])) {
                m <- m [which (nzchar (m))] [-1]
                m <- paste0 (m, collapse = ", ")
                cli::cli_text (paste0 (m, "."))
            }
        }
        return ()
    }

    if (!is.null (x$info$srr$missing_stds)) {
        cli::cli_alert_warning ("The following standards are missing:")
        cli::cli_li (x$info$srr$missing_stds)
    }

    cli::cli_alert_info ("'srr' report is at [{x$info$srr$report_file}].")
    message ("")
}

#' Format `srr` checks in markdown
#' @param checks Result of main \link{pkgcheck} function
#' @noRd
srr_checks_to_md <- function (checks) {

    if (is.null (checks$info$srr)) {
        return (NULL)
    }

    while (!nzchar (checks$info$srr$message [1])) {
        checks$info$srr$message <- checks$info$srr$message [-1]
    }

    sym <- ifelse (checks$info$srr$okay, symbol_tck (), symbol_crs ())
    srr_msg <- paste (sym, checks$info$srr$message [1])
    if (length (checks$info$srr$message) > 1L) {
        srr_msg <- paste0 (c (
            srr_msg,
            checks$info$srr$message [-1],
            collapse = "\n"
        ))
    }

    cat_plural <- ifelse (
        length (checks$info$srr$categories) == 1,
        "category",
        "categories"
    )
    cat_msg <- report_msg <- ""
    if (length (checks$info$srr$categories) > 0L) {
        cat_msg <- c (
            paste0 ("This package is in the following ", cat_plural, ":"),
            "",
            paste0 ("- *", checks$info$srr$categories, "*")
        )
        report_msg <- paste0 (
            "Click to see the [report of author-reported ",
            "standards compliance of the package with links to ",
            "associated lines of code](",
            report_file (checks),
            "), which can be re-generated locally by running the ",
            "[`srr_report()` function]",
            "(https://docs.ropensci.org/srr/reference/srr_report.html) ",
            "from within a local clone of the repository."
        )
    }

    c (
        paste0 (
            "### 1. rOpenSci Statistical Standards ",
            "([`srr` package]",
            "(https://github.com/ropensci-review-tools/srr))"
        ),
        "",
        cat_msg,
        "",
        srr_msg,
        "",
        report_msg,
        "",
        "---",
        ""
    )
}
