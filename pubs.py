import sys
import re
from collections import defaultdict
import configargparse
from typing import Dict, List

UW_STUDENTS = [
    "Xieyang Xu",
    "Tapan Chugh",
    "Xiangfeng Zhu",
    "Weixin Deng",
    "Anish Nyayachavadi",
    "Shubham Tiwari",
    "Wei Shen",
    "Brody Frank",
    "Natalie Neamtu",
    "Yuyao Wang",
]

POSTDOCS = [
    "Xiangyu Gao",
    "Sam Kumar",
    "Klaus-Tycho Forster",
    "Monia Ghobadi",
    "Hongqiang Liu",
]

MSR_STUDENTS = [
    "Nick Giannarakis",
    "Danyang Zhuo",
    "Arpit Gupta",
    "Aaron Gember-Jackson",
    "Ryan Beckett",
    "Seyed Fayaz",
    "Raajay Vishwanathan",
    "Xin Jin",
    "Hongqiang Liu",
    "Peng Sun",
    "Ari Fogel",
    "Rayman Preet Singh",
    "Luis Pedrosa",
    "Vijay Adhikari",
    "Yingying Chen",
    "Chun-Te Chu",
    "Chi-Yao Hong",
    "Jason Croft",
    "Colin Dixon",
    "Hossein Falaki",
    "Radhika Niranjan Mysore",
    "Patrick Verkaik",
    "Aruna Balasubramanian",
    "Lindsey Poole",
    "Krishna Ramachandran",
]


def print_header():
    print(
        """
<html>
<head>
  <title>ratul's publications</title>
</head>
<body bgcolor="#ffffff">
"""
    )


def print_footer():
    print(
        """
</body>
</html>
"""
    )


def print_by_topic(topic_order, topics, all_entries):
    print("<ul>")
    for topic in topic_order:
        if re.search(r"selected|ignore", topic):
            continue
        print(f'<li><a href="#{topic}">{topics[topic]}</a>')
    print("</ul>")

    for topic in topic_order:
        if re.search(r"selected|ignore", topic):
            continue
        print(f"<p><a name={topic}></a>\n<b>{topics[topic]}</b>")
        print(
            """
<table style="width: 100%;" cellpadding="2" cellspacing="2">
<tr><td width=10px><td></tr>
"""
        )
        for entry in all_entries:
            if re.search(topic, entry["topics"]):
                if re.search(r"ignore", entry["topics"]):
                    continue
                print_paper(entry)
        print("</table>")


def print_by_time(all_entries):
    last_printed_year = -1
    for entry in all_entries:
        year = entry["year"]
        if year != last_printed_year:
            print("</table>")
            print(f"<p><b>{year}</b>")
            print(
                """
<table style="width: 100%;" cellpadding="2" cellspacing="2">
<tr><td width=10px><td></tr>
"""
            )
            last_printed_year = year
        if re.search(r"ignore", entry["topics"]):
            continue
        print_paper(entry)


def print_pubtype(all_entries: List[Dict[str, str]]) -> None:
    pub_types = defaultdict(lambda: [])

    for entry in all_entries:
        pub_types[entry["pubtype"]].append(entry)

    print(f"Found pubtypes: {pub_types.keys()}", file=sys.stderr)

    for pub_type, entries in pub_types.items():
        print(f"<p><b>{pub_type}</b><br>")
        for entry in entries:
            if re.search(r"ignore", entry["topics"]):
                continue
            print_paper_pubtype(pub_type, entry)


def print_paper_pubtype(pub_type: str, entry: Dict[str, str]) -> None:
    print(f"printing {entry['paperKey']}", file=sys.stderr)

    print("<p>")
    if "impact" in entry:
        print("<sup>*</sup>", end="")

    authors = [author for author in entry["author"].split(" and ")]
    for index, author in enumerate(authors):
        if index == len(authors) - 1 and len(authors) != 1:
            # last author?
            print(f" and ", end="")
        else:
            print(f" ", end="")

        print(f"{author}", end="")

        # add a comma if we have more than two authors and this is not the last author
        if index < len(author) - 1 and len(author) > 2:
            print(",", end="")

        if author in UW_STUDENTS or author in MSR_STUDENTS:
            print("<sup>1</sup>", end="")

        if author in POSTDOCS:
            print("<sup>2</sup>", end="")

    title = re.sub(r"(\{|\})", "", entry["title"])
    print(f"    ``{title}''", end="")

    venue = (
        entry.get("booktitle")
        or entry.get("journal")
        or entry.get("howpublished")
        or "unknown"
    )
    print(f", <i>{venue}</i>", end="")

    if re.search(r"article", entry["paperType"]):
        print(f", {entry['volume']}({entry['number']})", end="")
    if "pages" in entry:
        print(f", pages {entry['pages']}", end="")
    print(f", {entry['month']} {entry['year']}.", end="")

    if "acceptancerate" in entry:
        print(f"    ({entry['acceptancerate']}% acceptance rate)", end="")
    if "citations" in entry:
        print(f"    ({entry['citations']} citations)", end="")
    if "note" in entry:
        print(f"    <b>({entry['note']})</b>")


def print_cv(topic_order, topics, all_entries):
    for topic in topic_order:
        if re.search(r"selected|ignore", topic):
            continue
        print(f"\\item {{\\bf {topics[topic]}}}")
        print("\\begin{innerlist}")
        for entry in all_entries:
            if re.search(topic, entry["topics"]):
                if re.search(r"ignore", entry["topics"]) or re.search(
                    r"misc", entry["paperType"]
                ):
                    continue
                author = entry["author"].replace(" and ", ", ")
                venue = (
                    entry.get("booktitle")
                    or entry.get("journal")
                    or entry.get("howpublished")
                    or "unknown"
                )
                title = re.sub(r"(\{|\})", "", entry["title"])
                print("\\item")
                if "impact" in entry:
                    print("\\hspace{-0.15in} * ")
                print(f"    {author},")
                print(f"    ``{title},''")
                print(f"     {{\\em {venue},}}")
                if re.search(r"article", entry["paperType"]):
                    print(f"    {entry['volume']}({entry['number']},")
                print(f"    {entry['month']} {entry['year']}.")
                if "acceptancerate" in entry:
                    print(f"    ({entry['acceptancerate']}\\% acceptance rate)")
                if "note" in entry:
                    print(f"    {{\\bf {entry['note']}}}")
        print("\\end{innerlist}")


def print_paper(entry):
    author = entry["author"].replace(" and ", ", ")
    venue = (
        entry.get("booktitle")
        or entry.get("journal")
        or entry.get("howpublished")
        or "unknown"
    )
    title = re.sub(r"(\{|\})", "", entry["title"])
    print(
        f"""
<a href={entry['URL']}><b>{title}</b></a><br>
{author}<br>
{venue}, {entry['year']}<br>
"""
    )
    if "note" in entry:
        print(f"<b>{entry['note']}</b><br>")
    if "resource" in entry:
        print(f"{entry['resource']}<br>")
    print("<br>")


def main():
    parser = configargparse.ArgParser(description="Process publication data.")
    parser.add_argument("--verbose", action="store_true", help="debug mode [off]")
    parser.add_argument(
        "--mode", type=str, default="time", choices=["time", "topic", "cv", "pubtype"]
    )
    parser.add_argument("files", nargs="+", help="list of files")
    args = parser.parse_args()

    topic_order = []
    topics = {}
    all_entries = []

    for file in args.files:
        with open(file, "r") as f:
            for line in f:
                if re.match(r"^\@comment", line) or re.match(r"^\s*$", line):
                    # ignore comments and blank lines
                    continue
                elif match := re.match(r"^([a-z]+)\s+:: (.+)$", line):
                    # topic lines at the top of the file
                    topic_key, topic = match.groups()
                    topics[topic_key] = topic
                    topic_order.append(topic_key)
                elif match := re.match(r"^\@([a-z]+)\{(.+)\,", line):
                    # the first line of an entry
                    paper_type, paper_key = match.groups()
                    all_entries.append({"paperType": paper_type, "paperKey": paper_key})
                elif match := re.match(r"\s+([a-zA-Z]+)=\{(.+)\}", line):
                    # following up lines of an entry
                    key, value = match.groups()
                    if key in all_entries[-1]:
                        raise ValueError(
                            f"duplicate {key=} in {all_entries[-1]['paperKey']}"
                        )
                    all_entries[-1][key] = value

    if args.mode == "time":
        print_header()
        print_by_time(all_entries)
        print_footer()
    elif args.mode == "topic":
        print_header()
        print_by_topic(topic_order, topics, all_entries)
        print_footer()
    elif args.mode == "cv":
        print_cv(topic_order, topics, all_entries)
    elif args.mode == "pubtype":
        print_header()
        print_pubtype(all_entries)
        print_footer()
    else:
        raise ValueError(f"unknown mode: {args.mode}")


if __name__ == "__main__":
    main()
