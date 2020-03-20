import datetime
from django.db import models
from django.utils import timezone
class Article(models.Model):
	article_title = models.CharField("Title", max_length = 200)
	article_text  = models.TextField("Text")
	pub_date  = models.DateTimeField("Date")

	def __str__(self):
		return self.article_title+" "+self.article_text

	def was_published_recently(self):
		return self.pub_date>=(timezone.now()-datetime.timedelta(days=7))


class Comment(models.Model):
	article = models.ForeignKey(Article, on_delete = models.CASCADE)
	author_name  = models.CharField("Author", max_length=50)
	comment_text  = models.CharField("comment text", max_length=200)

	def __str__(self):
		return self.author_name

	def get_full_information(self):
		return "Author: "+self.author_name+" Comment: "+self. comment_text