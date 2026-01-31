using System;
using System.Windows.Forms;
using System.Diagnostics;
using System.IO;
using System.ServiceProcess;

namespace RunWithPower
{
    public partial class Form1 : Form
    {
        private bool fileSelected = false;

        public Form1()
        {
            InitializeComponent();
            openFileDialog1.Filter = "Executables (*.exe)|*.exe|All files (*.*)|*.*";
            openFileDialog1.Title = "Select a file to run";
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
        }

        private void ResetButton()
        {
            fileSelected = false;
            button1.Text = "Browse";
            textBox1.Clear();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            // FIRST CLICK → Choose file
            if (!fileSelected)
            {
                if (openFileDialog1.ShowDialog() == DialogResult.OK)
                {
                    textBox1.Text = openFileDialog1.FileName;
                    button1.Text = "Run";
                    fileSelected = true;
                }
                return;
            }

            // SECOND CLICK → Run file
            if (!File.Exists(textBox1.Text))
            {
                MessageBox.Show("Selected file does not exist.");
                ResetButton();
                return;
            }

            string arguments;

            switch (comboBox1.Text)
            {
                case "Not chosen":
                    MessageBox.Show("Please choose an option!");
                    return; // let user select, don't reset

                case "Invoker":
                    arguments = $"-i \"{textBox1.Text}\"";
                    RunPsExec(arguments);
                    break;

                case "Administrator":
                    arguments = $"-h \"{textBox1.Text}\"";
                    RunPsExec(arguments);
                    break;

                case "System":
                    arguments = $"-s -i \"{textBox1.Text}\"";
                    RunPsExec(arguments);
                    break;

                case "TrustedInstaller":
                    RunAsTrustedInstaller(textBox1.Text);
                    break;

                default:
                    MessageBox.Show("Invalid option selected.");
                    return;
            }

            // AFTER RUN → back to choose mode
            ResetButton();
        }

        private void RunPsExec(string args)
        {
            try
            {
                if (!File.Exists("PsExec.exe"))
                {
                    MessageBox.Show("Error: PsExec.exe not found in the application folder!");
                    return;
                }

                Process.Start("PsExec.exe", args);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error running PsExec: {ex.Message}");
            }
        }

        private void RunAsTrustedInstaller(string applicationPath)
        {
            try
            {
                ServiceController sc = new ServiceController("TrustedInstaller");

                if (sc.Status != ServiceControllerStatus.Running)
                {
                    sc.Start();
                    sc.WaitForStatus(ServiceControllerStatus.Running, TimeSpan.FromSeconds(10));
                }

                Process[] proc = Process.GetProcessesByName("TrustedInstaller");

                if (proc.Length > 0)
                {
                    IamYourDaddy.Run(proc[0].Id, applicationPath);
                }
                else
                {
                    MessageBox.Show("Error: TrustedInstaller process not found.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error running as TrustedInstaller: {ex.Message}");
            }
        }
    }
}
