import re
import argparse


def read_terraform_file(filename):
    with open(filename, "r") as file:
        file_content = file.read()
    return file_content


def write_terraform_file(filename, sorted_vars):
    with open(filename, "w") as file:
        file.write(sorted_vars)


def sort_terraform_variables(content):
    # Revised regex pattern to match variable blocks with nested structures
    pattern = re.compile(r'variable\s+"[^"]+"\s+\{.*?\n}', re.DOTALL)
    variables = pattern.findall(content)
    # Sort variables alphabetically
    variables.sort(key=lambda x: re.search(r'variable\s+"([^"]+)"', x).group(1))
    return "\n\n".join(variables)


def parse_arguments():
    parser = argparse.ArgumentParser(description="Sort Terraform variables.")
    parser.add_argument(
        "-i",
        "--in-file",
        type=str,
        help="Input Terraform file",
        default="./variables.tf",
    )
    parser.add_argument(
        "-o",
        "--out-file",
        type=str,
        help="Output Terraform file",
        default="./variables.tf",
    )
    return parser.parse_args()


def main():
    args = parse_arguments()
    content = read_terraform_file(args.in_file)
    sorted_vars = sort_terraform_variables(content)
    write_terraform_file(args.out_file, sorted_vars)
    print(f"Sorted variables written to {args.out_file}")


if __name__ == "__main__":
    main()
