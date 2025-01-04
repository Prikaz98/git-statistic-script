#!/bin/bash

arg="$1"
if [ $arg = "--help" ]; then
    echo "--help"
    echo "Description: Script to calculate commits statistic by author"
    echo "Example: sh script.sh repo_dir days_since author (optional: Default all authors) days_until (optional: Default zero)"
else
    cd $1
    repo_dir="$1/.git"
    days_since="$2"
    authors="$3"
    if [ -z "$authors" ]; then
        authors=$(git log --pretty="%an" | sort -u | uniq)
    fi

    days_until="$4"
    if [ -z "$days_until" ]; then
        days_until="0"
    fi

    repo_path=$(pwd)
    for author in $authors
    do
        echo "Params: [:repo $repo_path :days_since $days_since :author $author :days_until $days_until]"

        lines_raw=$(git --git-dir=$repo_dir log --author="$author" --since="$days_since days ago" --until="$days_until days ago" --pretty=tformat: --numstat | \
            grep -e "\.py$" \
            -e "\.java$" \
            -e "\.c$" \
            -e "\.cpp$" \
            -e "\.cc$" \
            -e "\.cxx$" \
            -e "\.h$" \
            -e "\.cs$" \
            -e "\.js$" \
            -e "\.ts$" \
            -e "\.go$" \
            -e "\.rs$" \
            -e "\.kt$" \
            -e "\.kts$" \
            -e "\.html$" \
            -e "\.htm$" \
            -e "\.css$" \
            -e "\.php$" \
            -e "\.rb$" \
            -e "\.hs$" \
            -e "\.scala$" \
            -e "\.sc$" \
            -e "\.ex$" \
            -e "\.exs$" \
            -e "\.erl$" \
            -e "\.hrl$" \
            -e "\.sh$" \
            -e "\.pl$" \
            -e "\.pm$" \
            -e "\.lua$" \
            -e "\.el$" \
            -e "\.r$" \
            -e "\.R$" \
            -e "\.jl$" \
            -e "\.m$" \
            -e "\.swift$" \
            -e "\.dart$" \
            -e "\.asm$" \
            -e "\.s$" \
            -e "\.f$" \
            -e "\.for$" \
            -e "\.f90$" \
            -e "\.cob$" \
            -e "\.cbl$" \
            -e "\.sql$" \
            -e "\.yml$" \
            -e "\.yaml$" \
            -e "\.json$" \
            -e "\.xml$" | awk '{added+=$1; deleted+=$2} END {print added, deleted}')

        commits_count=$(git --git-dir=$repo_dir log --author="$author" --since="$days_since days ago" --until="$days_until days ago" --oneline | wc -l | awk '{$1=$1;print}')
        lines_added=$(echo "$lines_raw" | awk '{print $1}')
        lines_deleted=$(echo "$lines_raw" | awk '{print $2}')
      

        days_range=$((days_since - $days_until))
        commits_count_avg=$((commits_count / $days_range))
        lines_added_avg=$((lines_added / $days_range))
        lines_deleted_avg=$((lines_deleted / $days_range))

        echo "- commits: $commits_count (avg per day: $commits_count_avg)"
        echo "- lines added: $lines_added (avg per day: $lines_added_avg)"
        echo "- lines deleted: $lines_deleted (avg per day: $lines_deleted_avg)"
    done

    echo ""
    top_authors=$(git --git-dir=$repo_dir log --pretty=format:"%aN" | sort | uniq -c | sort -nr | head -n 5 | awk '{$1=""; print substr($0,2)}' | paste -sd, -)
    echo "- top authors: $top_authors"
    
fi
