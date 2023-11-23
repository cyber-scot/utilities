import re
import argparse


def read_terraform_file(filename):
    with open(filename, "r") as file:
        file_content = file.read()
    return file_content


def write_terraform_file(filename, sorted_vars):
    with open(filename, "w") as file:
        file.write(sorted_vars)


def sort_terraform_outputs(content):
    pattern = re.compile(r'output\s+"[^"]+"\s+\{.*?\n}', re.DOTALL)
    outputs = pattern.findall(content)
    outputs.sort(key=lambda x: re.search(r'output\s+"([^"]+)"', x).group(1))
    return "\n\n".join(outputs)


def parse_arguments():
    parser = argparse.ArgumentParser(description="Sort Terraform output variables.")
    parser.add_argument(
        "-i", "--in-file", type=str, help="Input Terraform file", default="./outputs.tf"
    )
    parser.add_argument(
        "-o",
        "--out-file",
        type=str,
        help="Output Terraform file",
        default="./outputs.tf",
    )
    return parser.parse_args()


def main():
    args = parse_arguments()
    content = read_terraform_file(args.in_file)
    sorted_outputs = sort_terraform_outputs(content)
    write_terraform_file(args.out_file, sorted_outputs)
    print(f"Sorted outputs written to {args.out_file}")


if __name__ == "__main__":
    main()
