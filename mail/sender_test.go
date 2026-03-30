package mail

import (
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/vctrthe/simplebank/util"
)

func TestSendEmailWithGmail(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping test in short mode.")
	}

	config, err := util.LoadConfig("..")
	require.NoError(t, err)

	sender := NewGmailSender(config.EmailSenderName, config.EmailSenderAddress, config.EmailSenderPassword)

	subject := "Test Email from Simple Bank"
	content := "<h1>Hello from Simple Bank!</h1><p>This is a test email sent using Gmail SMTP server.</p>"
	to := []string{"victorthe123@gmail.com"}
	attachFiles := []string{"../test-document.txt"}

	err = sender.SendEmail(subject, content, to, nil, nil, attachFiles)
	require.NoError(t, err)
}
