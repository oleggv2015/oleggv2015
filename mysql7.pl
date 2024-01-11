#!/usr/bin/perl
use strict;
use warnings;
use v5.18; # для функции say()
use Encode;
use DBI;
use XML::LibXML;
#use utf8;
#use open qw(:std :utf8);
use open ':encoding(cp1251)';


my $host="localhost";
my $port="3306";
my $db = "olegdb1";
my $username = "root";
my $password = '';
#my $charset="utf8";

# подключение к базе данных MySQL
my %attr = ( PrintError=>0,  # отключение отчетов об ошибках с помощью warn()
RaiseError=>1   # report error via die()
);
my $dbh = DBI->connect("DBI:mysql:$db:$host:$port",$username,$password,\%attr);

#устанавливаем кодировку
my $sql = "set names utf8";
my $sth = $dbh->prepare($sql);
$sth->execute();

my $parser = XML::LibXML->new();
my $xmldoc = $parser->parse_file ("i3001799.0a0") || die("Could not parse xml file\n");
#my $root = $xmldoc->getDocumentElement()|| die("Could not get Document Element \n");

open my $out, '>', 'mysql7.log';
#print $doc;
my @arr=();
my @findval = (
    'EDNo',
    'EDDate',
    'EDAuthor',
    'Sum',
    'TransKind',
    'Priority',
    'ReceiptDate',
    'ChargeOffDate',
    'SystemCode',
    'PaymentID',
    'PaymentPrecedence',
    'AccDocNo',
    'AccDocDate',
    'PersonalAcc',
    'INN',
    'KPP',
    'Name',
    'BIC',
    'CorrespAcc',
    'Purpose',
    'DrawerStatus',
    'CBC',
    'OKATO',
    'PaytReason',
    'TaxPeriod',
    'DocNo',
    'DocDate',
    'TaxPaytKind'
);
node_all( $xmldoc->getDocumentElement, 0);

#printf {$out} "@arr \n";

#  @arr= grep { $_ ne '' } @arr;
my $sizearr=($#arr+1)/34;
#say $#arr, $sizearr;
#	for(my $j=0;$j<=$#arr;$j++) {
#     printf {$out} "$arr[$j] \n"	
#}
	for(my $j1=0;$j1<$sizearr;$j1++) {
          my @value=();
          for(my $j2=0;$j2<=33;$j2++) {
            push(@value,$arr[$j1*34+$j2]);
#     printf {$out} "$arr[$j1*10+$j2]"	 
                                         }
     printf {$out} "@value \n";

#$sql = "INSERT INTO payments (EDNO, EDDATE, EDAUTHOR, SUM, TRANSKIND, PRIORITY, RECEIPTDATE, CHARGEOFFDATE, SYSTEMCODE, PAYMENTID,
#PAYMENTPRECEDENCE, ACCDOCNO, ACCDOCDATE, PERSONLAACC, INN, KPP, NAME, BIC, CORRESPACC, PERSONALACCB, INNB, KPPB,
#NAMEB, BICB, CORRESPACCB) VALUES (" . $value[0] . ",\'" . $value[1] . "\'," . $value[2] . "," . $value[3] . "," .
#$value[4] . "," . $value[5] . ",\'" . $value[6] . "\',\'" . $value[7] . "\'," . $value[8] . "," . $value[9] . "," .
#$value[10] . "," . $value[11] . ",\'" . $value[12] . "\'," . $value[13] . "," . $value[14] . "," . $value[15] . ",\'" .
#$value[16] . "\'," . $value[17] . "," . $value[18] . "," . $value[19] . "," . $value[20] . "," . $value[21] . ",\'" .
#$value[22] . "\'," . $value[23] . "," . $value[24] . ")";

$sql = "INSERT INTO payments (EDNO, EDDATE, EDAUTHOR, SUM, TRANSKIND, PRIORITY, RECEIPTDATE, CHARGEOFFDATE, SYSTEMCODE, PAYMENTID,
PAYMENTPRECEDENCE, PURPOSE, ACCDOCNO, ACCDOCDATE, PERSONLAACC, INN, KPP, NAME, BIC, CORRESPACC, PERSONALACCB, INNB, KPPB,
NAMEB, BICB, CORRESPACCB, DRAWERSTATUS, CBC, OKATO, PAYTREASON, TAXPERIOD, DOCNO, DOCDATE, TAXPAYTKIND) VALUES (";

          for(my $j2=0;$j2<=33;$j2++) {
            if ($j2 eq 33) { 
               $sql = $sql . "\'" . $value[$j2] . "\')";
                           }
            else {
               $sql = $sql . "\'" . $value[$j2] . "\',";
                 }
                                      }

#say $sql;

$sth = $dbh->prepare($sql);

# выполнение запроса
$sth->execute();
                                          }  
$sth->finish();

# отключитесь от базы данных MySQL
$dbh->disconnect();

sub node_all {
    my ($node, $depth) = @_;
#    my ($node, $depth, $edno101, $sum101) = @_;
#    printf {$out} "$node\n";
    return unless( $node->nodeType eq &XML_ELEMENT_NODE );

             if ($depth ne 0)  {
                    foreach (@findval) {
                     if ($node->hasAttribute($_)) {
                    push(@arr, $node->getAttribute($_));
                                                  }
                     else   {
                        #printf {$out} "no attribute \n";
                      if ($node->getChildrenByTagName($_)) {

                    my $name=$node->getChildrenByTagName($_);
                    push(@arr, $name);
                                                                       }
    
                            }
                                     }
                               }
#        my $nodename=$node->nodeName;
#      if ($avalue && $nodename eq "Payer") {
#    printf {$out} "$nodename, $depth, $ed, $sum, $avalue; \n";
#            }
    foreach my $child ( $node->getChildnodes ) {
        node_all( $child, $depth+1 );
    }
}

