#!/usr/bin/env python3
"""
CODEOWNERS Management & Validation Scripts
Tools for managing, validating, and automating CODEOWNERS file operations
"""

import re
import json
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Set
from dataclasses import dataclass
from datetime import datetime, timedelta
from collections import defaultdict


@dataclass
class CodeOwnerEntry:
    """Represents a single CODEOWNERS entry"""
    pattern: str
    owners: List[str]
    line_number: int


class CodeOwnersValidator:
    """Validates CODEOWNERS file for syntax and consistency"""

    def __init__(self, codeowners_path: str = ".github/CODEOWNERS"):
        self.path = Path(codeowners_path)
        self.entries: List[CodeOwnerEntry] = []
        self.errors: List[str] = []
        self.warnings: List[str] = []

    def load(self) -> bool:
        """Load and parse CODEOWNERS file"""
        if not self.path.exists():
            self.errors.append(f"CODEOWNERS file not found at {self.path}")
            return False

        try:
            with open(self.path, 'r') as f:
                lines = f.readlines()

            for line_num, line in enumerate(lines, 1):
                line = line.rstrip('\n')

                # Skip comments and empty lines
                if not line.strip() or line.strip().startswith('#'):
                    continue

                # Parse pattern and owners
                parts = line.split()
                if len(parts) < 2:
                    self.warnings.append(f"Line {line_num}: Invalid format '{line}'")
                    continue

                pattern = parts[0]
                owners = parts[1:]

                self.entries.append(CodeOwnerEntry(
                    pattern=pattern,
                    owners=owners,
                    line_number=line_num
                ))

            return True

        except Exception as e:
            self.errors.append(f"Error reading file: {str(e)}")
            return False

    def validate_syntax(self) -> bool:
        """Validate CODEOWNERS syntax"""
        valid = True

        for entry in self.entries:
            # Check pattern validity
            if not self._is_valid_pattern(entry.pattern):
                self.warnings.append(
                    f"Line {entry.line_number}: "
                    f"Invalid pattern '{entry.pattern}'"
                )
                valid = False

            # Check owner format
            for owner in entry.owners:
                if not self._is_valid_owner(owner):
                    self.errors.append(
                        f"Line {entry.line_number}: "
                        f"Invalid owner format '{owner}'. "
                        f"Use @username or @org/team or email@example.com"
                    )
                    valid = False

        return valid

    def check_duplicates(self) -> bool:
        """Check for duplicate patterns"""
        seen: Dict[str, int] = {}
        valid = True

        for entry in self.entries:
            if entry.pattern in seen:
                self.warnings.append(
                    f"Duplicate pattern '{entry.pattern}' "
                    f"at lines {seen[entry.pattern]} and {entry.line_number}. "
                    f"Last match wins."
                )
                valid = False
            else:
                seen[entry.pattern] = entry.line_number

        return valid

    def check_overlaps(self) -> bool:
        """Check for potentially overlapping patterns"""
        valid = True

        for i, entry1 in enumerate(self.entries):
            for entry2 in self.entries[i + 1:]:
                if self._patterns_overlap(entry1.pattern, entry2.pattern):
                    # Only warn if ownership differs
                    if set(entry1.owners) != set(entry2.owners):
                        self.warnings.append(
                            f"Overlapping patterns at lines {entry1.line_number} "
                            f"and {entry2.line_number}: "
                            f"'{entry1.pattern}' vs '{entry2.pattern}'. "
                            f"Last match will take precedence."
                        )

        return valid

    def analyze_coverage(self) -> Dict[str, List[str]]:
        """Analyze code ownership coverage"""
        coverage = defaultdict(list)

        for entry in self.entries:
            for owner in entry.owners:
                coverage[owner].append(entry.pattern)

        return dict(coverage)

    def report(self) -> str:
        """Generate validation report"""
        report = []
        report.append("=" * 60)
        report.append("CODEOWNERS Validation Report")
        report.append("=" * 60)
        report.append(f"File: {self.path}")
        report.append(f"Entries: {len(self.entries)}")
        report.append(f"Timestamp: {datetime.now().isoformat()}")
        report.append("")

        if self.errors:
            report.append(f"ERRORS ({len(self.errors)}):")
            for error in self.errors:
                report.append(f"  ✗ {error}")
            report.append("")

        if self.warnings:
            report.append(f"WARNINGS ({len(self.warnings)}):")
            for warning in self.warnings:
                report.append(f"  ⚠ {warning}")
            report.append("")

        # Coverage analysis
        coverage = self.analyze_coverage()
        report.append("COVERAGE ANALYSIS:")
        for owner in sorted(coverage.keys()):
            patterns = coverage[owner]
            report.append(f"  {owner}: {len(patterns)} patterns")

        report.append("")
        report.append(f"Status: {'✓ VALID' if not self.errors else '✗ INVALID'}")
        report.append("=" * 60)

        return "\n".join(report)

    @staticmethod
    def _is_valid_pattern(pattern: str) -> bool:
        """Validate file pattern syntax"""
        # Basic pattern validation
        invalid_chars = set('<>"|?')
        return not any(c in pattern for c in invalid_chars)

    @staticmethod
    def _is_valid_owner(owner: str) -> bool:
        """Validate owner format"""
        # Check for @username, @org/team, or email
        user_pattern = r'^@[\w\-]+$'
        team_pattern = r'^@[\w\-]+/[\w\-]+$'
        email_pattern = r'^[\w\.\-]+@[\w\.\-]+$'

        return (re.match(user_pattern, owner) or
                re.match(team_pattern, owner) or
                re.match(email_pattern, owner))

    @staticmethod
    def _patterns_overlap(pattern1: str, pattern2: str) -> bool:
        """Check if two patterns might overlap"""
        # Simple overlap detection
        # In real implementation, would use gitignore pattern matching
        p1_parts = set(pattern1.split('/'))
        p2_parts = set(pattern2.split('/'))

        # If one pattern is more specific subset of other, they overlap
        return p1_parts.issubset(p2_parts) or p2_parts.issubset(p1_parts)


class CodeOwnersRotationManager:
    """Manage reviewer rotation schedules"""

    def __init__(self, rotation_config_path: str = ".github/config/rotation.json"):
        self.config_path = Path(rotation_config_path)
        self.rotations: Dict = {}

    def load_config(self) -> bool:
        """Load rotation configuration"""
        if not self.config_path.exists():
            print(f"Warning: Config file {self.config_path} not found")
            return False

        try:
            with open(self.config_path, 'r') as f:
                self.rotations = json.load(f)
            return True
        except Exception as e:
            print(f"Error loading config: {e}")
            return False

    def generate_quarterly_rotation(self, team: str, members: List[str],
                                   quarters: int = 1) -> Dict:
        """Generate rotation schedule for upcoming quarters"""
        if len(members) < 2:
            print("Warning: Team should have at least 2 members for rotation")

        rotation_schedule = {}
        quarter_names = ['Q1', 'Q2', 'Q3', 'Q4']
        start_year = datetime.now().year
        start_quarter = ((datetime.now().month - 1) // 3) + 1

        for q in range(quarters):
            quarter_idx = (start_quarter + q - 1) % 4
            year_offset = (start_quarter + q - 1) // 4
            quarter_label = f"{quarter_names[quarter_idx]}{start_year + year_offset}"

            # Rotate members
            rotation_index = q % len(members)
            rotation_schedule[quarter_label] = {
                'primary': members[rotation_index],
                'secondary': members[(rotation_index + 1) % len(members)],
                'backup': members[(rotation_index + 2) % len(members)]
            }

        return {
            'team': team,
            'members': members,
            'rotation_schedule': rotation_schedule
        }

    def save_rotation(self, rotation: Dict) -> bool:
        """Save rotation schedule to file"""
        try:
            self.config_path.parent.mkdir(parents=True, exist_ok=True)
            with open(self.config_path, 'w') as f:
                json.dump(rotation, f, indent=2)
            return True
        except Exception as e:
            print(f"Error saving rotation: {e}")
            return False

    def get_current_reviewer(self, team: str) -> str:
        """Get current primary reviewer for a team"""
        current_quarter = self._get_current_quarter()

        if team not in self.rotations:
            return "No rotation configured"

        rotation = self.rotations[team]
        if current_quarter in rotation.get('rotation_schedule', {}):
            return rotation['rotation_schedule'][current_quarter]['primary']

        return "Not found"

    @staticmethod
    def _get_current_quarter() -> str:
        """Get current quarter label"""
        now = datetime.now()
        quarter = ((now.month - 1) // 3) + 1
        return f"Q{quarter}{now.year}"


class CodeOwnersGenerator:
    """Generate CODEOWNERS files from configuration"""

    def __init__(self, config: Dict):
        self.config = config

    def generate(self) -> str:
        """Generate CODEOWNERS file content"""
        lines = []

        # Header
        lines.append("# ============================================================================")
        lines.append("# CODEOWNERS - Generated Configuration")
        lines.append("# ============================================================================")
        lines.append(f"# Generated: {datetime.now().isoformat()}")
        lines.append("# Update frequency: Quarterly")
        lines.append("# ============================================================================")
        lines.append("")

        # Global fallback
        if 'default_owner' in self.config:
            lines.append("# Default owner")
            lines.append(f"*    {' '.join(self.config['default_owner'])}")
            lines.append("")

        # Sections
        for section in self.config.get('sections', []):
            lines.append("# " + ("=" * 74))
            lines.append(f"# {section['name']}")
            lines.append("# " + ("=" * 74))
            lines.append("")

            for entry in section.get('entries', []):
                pattern = entry['pattern']
                owners = ' '.join(entry['owners'])
                lines.append(f"{pattern:40} {owners}")

            lines.append("")

        return "\n".join(lines)

    def save(self, output_path: str = ".github/CODEOWNERS") -> bool:
        """Save generated CODEOWNERS to file"""
        try:
            content = self.generate()
            Path(output_path).parent.mkdir(parents=True, exist_ok=True)
            with open(output_path, 'w') as f:
                f.write(content)
            print(f"Generated CODEOWNERS saved to {output_path}")
            return True
        except Exception as e:
            print(f"Error saving CODEOWNERS: {e}")
            return False


class EscalationManager:
    """Manage PR escalation rules and automation"""

    def __init__(self, escalation_config_path: str = ".github/config/escalation.json"):
        self.config_path = Path(escalation_config_path)
        self.rules: Dict = {}

    def load_rules(self) -> bool:
        """Load escalation rules"""
        if not self.config_path.exists():
            print(f"Warning: Escalation config not found at {self.config_path}")
            return False

        try:
            with open(self.config_path, 'r') as f:
                self.rules = json.load(f)
            return True
        except Exception as e:
            print(f"Error loading escalation rules: {e}")
            return False

    def should_escalate(self, pr_data: Dict) -> Tuple[bool, int, str]:
        """
        Determine if PR should be escalated

        Returns: (should_escalate, level, reason)
        """
        escalation_level = 0
        reasons = []

        # Check time-based rules
        created_at = datetime.fromisoformat(pr_data.get('created_at', ''))
        hours_elapsed = (datetime.now() - created_at).total_seconds() / 3600

        if hours_elapsed > 24 and not pr_data.get('has_approval'):
            escalation_level = max(escalation_level, 2)
            reasons.append("No approval after 24 hours")

        if hours_elapsed > 48 and not pr_data.get('has_approval'):
            escalation_level = max(escalation_level, 3)
            reasons.append("No approval after 48 hours")

        # Check file-based rules
        changed_files = pr_data.get('changed_files', [])
        risk_patterns = self.rules.get('file_patterns', {})

        for pattern, risk_level in risk_patterns.items():
            if any(re.match(pattern, f) for f in changed_files):
                escalation_level = max(escalation_level, risk_level)
                reasons.append(f"File pattern matched: {pattern}")

        # Check size-based rules
        additions = pr_data.get('additions', 0)
        if additions > self.rules.get('large_pr_threshold', 500):
            escalation_level = max(escalation_level, 1)
            reasons.append(f"Large PR: {additions} additions")

        return escalation_level > 0, escalation_level, "; ".join(reasons)

    def get_escalation_message(self, level: int) -> str:
        """Get notification message for escalation level"""
        messages = {
            1: "This PR needs attention - escalated to team lead",
            2: "This PR requires priority review - escalated to manager",
            3: "This PR is critical - escalated to director",
        }
        return messages.get(level, "PR escalated")


# CLI Interface
def main():
    """Command-line interface"""
    import argparse

    parser = argparse.ArgumentParser(description="CODEOWNERS Management Tools")
    subparsers = parser.add_subparsers(dest='command', help='Commands')

    # Validate command
    validate_parser = subparsers.add_parser('validate', help='Validate CODEOWNERS file')
    validate_parser.add_argument('--file', default='.github/CODEOWNERS')

    # Rotation command
    rotation_parser = subparsers.add_parser('rotate', help='Generate rotation schedule')
    rotation_parser.add_argument('--team', required=True)
    rotation_parser.add_argument('--members', required=True, nargs='+')
    rotation_parser.add_argument('--quarters', type=int, default=4)

    # Generate command
    generate_parser = subparsers.add_parser('generate', help='Generate CODEOWNERS')
    generate_parser.add_argument('--config', required=True)
    generate_parser.add_argument('--output', default='.github/CODEOWNERS')

    args = parser.parse_args()

    if args.command == 'validate':
        validator = CodeOwnersValidator(args.file)
        validator.load()
        validator.validate_syntax()
        validator.check_duplicates()
        validator.check_overlaps()
        print(validator.report())
        sys.exit(0 if not validator.errors else 1)

    elif args.command == 'rotate':
        manager = CodeOwnersRotationManager()
        rotation = manager.generate_quarterly_rotation(args.team, args.members, args.quarters)
        manager.save_rotation(rotation)
        print(json.dumps(rotation, indent=2))

    elif args.command == 'generate':
        with open(args.config) as f:
            config = json.load(f)
        generator = CodeOwnersGenerator(config)
        generator.save(args.output)

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
