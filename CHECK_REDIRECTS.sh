#!/usr/bin/env bash
# Run: bash CHECK_REDIRECTS.sh
# Tests common host/url variants and prints initial and final headers

set -eu

URLS=(
  "http://shayantaherkhani.ir/"
  "https://shayantaherkhani.ir/"
  "http://www.shayantaherkhani.ir/"
  "https://www.shayantaherkhani.ir/"
  "https://shayantaherkhani.github.io/"
)

echo "CHECK_REDIRECTS: testing ${#URLS[@]} URLs"
for url in "${URLS[@]}"; do
  echo
  echo "================================================================"
  echo "URL: $url"
  echo "-- Initial response (no redirects followed) --"
  # show only the first 40 header lines to keep output readable
  curl -I -sS --max-time 15 "$url" | sed -n '1,40p' || echo "(request failed)"

  echo
  echo "-- Final response (follow redirects, show final URL and headers) --"
  # show the final effective url then the final response headers
  final_hdrs=$(curl -I -sS -L --max-redirs 10 --max-time 30 -w "\nFinal-URL: %{url_effective}\n" "$url" 2>/dev/null || true)
  if [ -z "$final_hdrs" ]; then
    echo "(follow request failed)"
  else
    echo "$final_hdrs" | sed -n '1,80p'
  fi

  echo
  echo "-- Location header (initial) --"
  curl -I -sS --max-time 15 "$url" | awk 'BEGIN{IGNORECASE=1} /Location:/{print;found=1} END{if(!found) print "(none)"}'

  echo "================================================================"
done

echo
echo "Done. Interpret results as follows:"
echo "- Initial response should be a 301/308 (or 302 temporarily) when a redirect is expected." 
echo "- The Location header should point to https://shayantaherkhani.ir/ (canonical host)."
echo "- Final-URL (following redirects) should be the canonical https://shayantaherkhani.ir/..."

exit 0
