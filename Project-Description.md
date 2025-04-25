Automated & Portable WordPress Docker Environment with GHCR Integration

📘 Project Description
This project aims to simplify the setup, customization, export, and redeployment of WordPress environments using Docker. With the help of a few automated bash scripts, users will be able to launch a new WordPress instance, apply themes and plugins, package that instance into a Docker image, and push it to GitHub Container Registry (GHCR) for seamless redeployment anywhere.

The goal is to make the entire process fast, repeatable, and developer-friendly — ideal for client projects, staging sites, backups, and rapid prototyping.

🎯 Project Objective
The objective is to deliver a highly automated toolkit for managing portable WordPress environments. The system should allow users to:
● Launch WordPress locally or on a server with minimal input.
● Customize and persist content, plugins, and themes.
● Export the full environment as a Docker image.
● Store it securely in GHCR.
● Re-deploy it on any server instantly with the same configuration and data.
● Use clean, well-documented bash scripts to ensure ease of use.

All components will be tested and verified on live Linux servers to ensure consistent, reliable behavior across environments.

🧩 Key Features
● One-command initialization of WordPress using Docker.
● GHCR integration to store and pull custom WordPress images.
● Exportable environment including themes, plugins, content, and database.
● Scripted import to spin up a cloned WordPress site anywhere.
● Custom DB environment support via environment variables.
● PHP upload and execution configuration override for production-readiness.
● Secure local-only port binding (127.0.0.1:8000) by default (unless changed by the user).
● Proper documentation for every step and component.

📁 Project Components
File                  Purpose
init-wordpress.sh     Launch a new WordPress container with custom DB and PHP settings
export-wordpress.sh   Package and push current container as a Docker image to GHCR
import-wordpress.sh   Pull and run a custom WordPress image from GHCR
README.md             Document installation, usage, and setup
.env.example          Provide a sample for setting DB and GHCR values
uploads.ini           Configuration file to override PHP limits in the container

⚙ Technical Requirements

Environment Variables (to be used in setup)

WordPress Container:
● WORDPRESS_DB_HOST
● WORDPRESS_DB_USER
● WORDPRESS_DB_PASSWORD
● WORDPRESS_DB_NAME

MySQL Container:
● MYSQL_DATABASE
● MYSQL_USER
● MYSQL_PASSWORD
● MYSQL_ROOT_PASSWORD

PHP Upload Configuration
The following will be injected into the container to bypass default file size and time limits in WordPress:

cat << 'EOF_UPLOADS' > uploads.ini
file_uploads = On
memory_limit = 512M
upload_max_filesize = 512M
post_max_size = 512M
max_execution_time = 1200
max_input_time = 600
EOF_UPLOADS

Port Binding
To ensure security and clarity:
ports:
  - "127.0.0.1:8000:80"
This ensures the WordPress site is accessible only from localhost unless the user explicitly changes the mapping.

🧪 Testing & Deployment Plan

Servers for Simulation
Server        Purpose                 IPv4               Login
Server 1      Initialization + Export 157.180.71.199     root / L7uvEuudspFLiCaCrgcn
Server 2      Import + Validation     95.216.140.118     root / gTt9XvRPJhvCCgpPV4pd

Test Flow

On Server 1:
1. Run init-wordpress.sh
2. Access WordPress at http://127.0.0.1:8000
3. Customize with a theme (e.g., Astra) and plugin (e.g., Elementor)
4. Create a post/page
5. Run export-wordpress.sh ghcr.io/<user>/wordpress-custom:v1

On Server 2:
1. Run import-wordpress.sh ghcr.io/<user>/wordpress-custom:v1
2. Verify WordPress runs on port 8000
3. Confirm that theme, plugin, and post are preserved

📖 Documentation
All scripts and setup steps will be properly documented in README.md, covering:
● Setup instructions
● Environment configuration
● GHCR login & usage
● Troubleshooting tips
● Example usage flows

✅ Summary
This project will empower developers and sysadmins to:
● Launch new WordPress setups quickly.
● Customize and save full WordPress environments.
● Distribute or replicate them anywhere with GHCR.
● Maintain clean, reliable, and documented automation using just bash and Docker.
